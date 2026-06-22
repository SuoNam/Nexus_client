#include "SystemMonitor.h"
#include <QFile>
#include <QTextStream>
#include <algorithm>
#include <cmath>

// ── 网卡名：根据 RK3528 实际接口修改 ─────────────────────────
// 用 `ip link` 或 `cat /proc/net/dev` 查看接口名
const QString SystemMonitor::WIRED_IFACE   =
    qEnvironmentVariable("NEXUS_WIRED_IFACE",   "enx00e04c525f38");
const QString SystemMonitor::HOTSPOT_IFACE =
    qEnvironmentVariable("NEXUS_HOTSPOT_IFACE", "wlx90de80f32a0e");

SystemMonitor::SystemMonitor(QObject *parent) : QObject(parent)
{
    m_wiredDownH.fill(0.0,   HIST_LEN);
    m_wiredUpH.fill(0.0,     HIST_LEN);
    m_hotspotDownH.fill(0.0, HIST_LEN);
    m_hotspotUpH.fill(0.0,   HIST_LEN);

    connect(&m_timer, &QTimer::timeout, this, &SystemMonitor::sample);
}

void SystemMonitor::start()
{
    // 预读一次作为基准，避免首次计算出现大幅跳变
    m_lastCpu = readCpuTimes();
    m_lastNet = readNetBytes();
    m_elapsed.start();

    m_timer.setInterval(POLL_INTERVAL_MS);
    m_timer.start();
}

void SystemMonitor::sample()
{
    const double intervalSec =
        std::max(0.5, static_cast<double>(m_elapsed.restart()) / 1000.0);

    // ── CPU ───────────────────────────────────────────────────
    CpuTimes cur = readCpuTimes();
    if (m_lastCpu.total > 0) {
        const qint64 dTotal = cur.total - m_lastCpu.total;
        const qint64 dIdle  = cur.idle  - m_lastCpu.idle;
        m_cpuUsage = (dTotal > 0)
                     ? std::round((1.0 - static_cast<double>(dIdle) / dTotal) * 1000.0) / 10.0
                     : 0.0;
    }
    m_lastCpu = cur;

    // ── 内存 ──────────────────────────────────────────────────
    m_memUsage = readMemUsage(m_totalMemGB, m_freeMemGB);

    // ── 负载 ──────────────────────────────────────────────────
    m_loadAvg = readLoadAvg();

    // ── 网速 ──────────────────────────────────────────────────
    auto curNet = readNetBytes();
    if (!m_lastNet.isEmpty()) {
        auto speedMB = [&](const QString &iface, bool rx) -> double {
            if (!curNet.contains(iface) || !m_lastNet.contains(iface)) return 0.0;
            const qint64 c = rx ? curNet[iface].rx : curNet[iface].tx;
            const qint64 l = rx ? m_lastNet[iface].rx : m_lastNet[iface].tx;
            return std::max(0.0, static_cast<double>(c - l) / (1024.0 * 1024.0 * intervalSec));
        };
        m_wiredUp     = speedMB(WIRED_IFACE,   true);
        m_wiredDown   = speedMB(WIRED_IFACE,   false);
        m_hotspotUp   = speedMB(HOTSPOT_IFACE, true);
        m_hotspotDown = speedMB(HOTSPOT_IFACE, false);
    }
    m_lastNet = curNet;

    push(m_wiredDownH,   m_wiredDown);
    push(m_wiredUpH,     m_wiredUp);
    push(m_hotspotDownH, m_hotspotDown);
    push(m_hotspotUpH,   m_hotspotUp);

    emit statsChanged();
    emit historyChanged();
}

// ── /proc/stat ────────────────────────────────────────────────
SystemMonitor::CpuTimes SystemMonitor::readCpuTimes()
{
    QFile f("/proc/stat");
    if (!f.open(QIODevice::ReadOnly)) return {};
    const QByteArray line = f.readLine();  // 第一行: "cpu  ..."
    f.close();

    QTextStream ts(line);
    QString tag;
    ts >> tag;

    qint64 user, nice, system, idle, iowait, irq, softirq;
    ts >> user >> nice >> system >> idle >> iowait >> irq >> softirq;

    CpuTimes ct;
    ct.idle  = idle + iowait;
    ct.total = user + nice + system + idle + iowait + irq + softirq;
    return ct;
}

// ── /proc/meminfo ─────────────────────────────────────────────
double SystemMonitor::readMemUsage(double &totalGB, double &freeGB)
{
    QFile f("/proc/meminfo");
    if (!f.open(QIODevice::ReadOnly)) return 0.0;

    qint64 memTotal = 0, memFree = 0, buffers = 0, cached = 0;
    auto parseKB = [](const QString &line) -> qint64 {
        // "MemTotal:    8192 kB" → 8192
        const QStringList parts = line.simplified().split(' ');
        return (parts.size() >= 2) ? parts[1].toLongLong() : 0LL;
    };

    while (!f.atEnd()) {
        const QString line = f.readLine();
        if      (line.startsWith("MemTotal:"))  memTotal = parseKB(line);
        else if (line.startsWith("MemFree:"))   memFree  = parseKB(line);
        else if (line.startsWith("Buffers:"))   buffers  = parseKB(line);
        else if (line.startsWith("Cached:") &&
                 !line.startsWith("CachedSwap:")) cached = parseKB(line);
        if (memTotal && memFree && buffers && cached) break;
    }
    f.close();

    if (memTotal == 0) return 0.0;
    const qint64 used = memTotal - memFree - buffers - cached;
    totalGB = static_cast<double>(memTotal) / (1024.0 * 1024.0);
    freeGB  = static_cast<double>(memFree + buffers + cached) / (1024.0 * 1024.0);
    return std::round(static_cast<double>(used) / memTotal * 1000.0) / 10.0;
}

// ── /proc/loadavg ─────────────────────────────────────────────
double SystemMonitor::readLoadAvg()
{
    QFile f("/proc/loadavg");
    if (!f.open(QIODevice::ReadOnly)) return 0.0;
    double load1 = 0.0;
    QTextStream(&f) >> load1;
    return load1;
}

// ── /proc/net/dev ─────────────────────────────────────────────
QMap<QString, SystemMonitor::NetBytes> SystemMonitor::readNetBytes()
{
    QMap<QString, NetBytes> result;
    QFile f("/proc/net/dev");
    if (!f.open(QIODevice::ReadOnly)) return result;

    f.readLine();  // 跳过标题行1
    f.readLine();  // 跳过标题行2
    while (!f.atEnd()) {
        const QString line = f.readLine().trimmed();
        const int colon = line.indexOf(':');
        if (colon < 0) continue;

        const QString iface = line.left(colon).trimmed();
        const QStringList fields = line.mid(colon + 1).trimmed().split(' ', Qt::SkipEmptyParts);
        if (fields.size() < 9) continue;

        NetBytes nb;
        nb.rx = fields[0].toLongLong();  // 接收字节 (download)
        nb.tx = fields[8].toLongLong();  // 发送字节 (upload)
        result[iface] = nb;
    }
    return result;
}

// ── helpers ───────────────────────────────────────────────────
void SystemMonitor::push(QVector<double> &v, double val)
{
    v.removeFirst();
    v.append(val);
}

QVariantList SystemMonitor::toVL(const QVector<double> &v)
{
    QVariantList out;
    out.reserve(v.size());
    for (double d : v) out << d;
    return out;
}
