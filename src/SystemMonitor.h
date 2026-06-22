#pragma once
#include <QObject>
#include <QTimer>
#include <QElapsedTimer>
#include <QVector>
#include <QVariantList>
#include <QMap>

// 直接读 /proc/* 采集系统状态，无需外部服务
class SystemMonitor : public QObject {
    Q_OBJECT

    Q_PROPERTY(double cpuUsage    READ cpuUsage    NOTIFY statsChanged)
    Q_PROPERTY(double memUsage    READ memUsage    NOTIFY statsChanged)
    Q_PROPERTY(double loadAvg     READ loadAvg     NOTIFY statsChanged)
    Q_PROPERTY(double totalMemGB  READ totalMemGB  NOTIFY statsChanged)
    Q_PROPERTY(double freeMemGB   READ freeMemGB   NOTIFY statsChanged)
    Q_PROPERTY(double wiredUp     READ wiredUp     NOTIFY statsChanged)
    Q_PROPERTY(double wiredDown   READ wiredDown   NOTIFY statsChanged)
    Q_PROPERTY(double hotspotUp   READ hotspotUp   NOTIFY statsChanged)
    Q_PROPERTY(double hotspotDown READ hotspotDown NOTIFY statsChanged)
    Q_PROPERTY(bool   connected   READ connected   NOTIFY connectedChanged)

    Q_PROPERTY(QVariantList wiredDownHist   READ wiredDownHist   NOTIFY historyChanged)
    Q_PROPERTY(QVariantList wiredUpHist     READ wiredUpHist     NOTIFY historyChanged)
    Q_PROPERTY(QVariantList hotspotDownHist READ hotspotDownHist NOTIFY historyChanged)
    Q_PROPERTY(QVariantList hotspotUpHist   READ hotspotUpHist   NOTIFY historyChanged)

public:
    static constexpr int    HIST_LEN        = 60;
    static constexpr int    POLL_INTERVAL_MS = 2000;

    // 修改此处以匹配 RK3528 上的网卡名（ip link 查看）
    static const QString WIRED_IFACE;
    static const QString HOTSPOT_IFACE;

    explicit SystemMonitor(QObject *parent = nullptr);

    // WebSocket 版遗留接口，本地版忽略参数直接启动轮询
    void connectToServer(const QString & /*unused*/) { start(); }
    void start();

    double cpuUsage()    const { return m_cpuUsage; }
    double memUsage()    const { return m_memUsage; }
    double loadAvg()     const { return m_loadAvg; }
    double totalMemGB()  const { return m_totalMemGB; }
    double freeMemGB()   const { return m_freeMemGB; }
    double wiredUp()     const { return m_wiredUp; }
    double wiredDown()   const { return m_wiredDown; }
    double hotspotUp()   const { return m_hotspotUp; }
    double hotspotDown() const { return m_hotspotDown; }
    bool   connected()   const { return true; }  // 本地读取始终"已连接"

    QVariantList wiredDownHist()   const { return toVL(m_wiredDownH); }
    QVariantList wiredUpHist()     const { return toVL(m_wiredUpH); }
    QVariantList hotspotDownHist() const { return toVL(m_hotspotDownH); }
    QVariantList hotspotUpHist()   const { return toVL(m_hotspotUpH); }

signals:
    void statsChanged();
    void connectedChanged();
    void historyChanged();

private slots:
    void sample();

private:
    struct CpuTimes { qint64 total = 0, idle = 0; };
    struct NetBytes  { qint64 rx    = 0, tx   = 0; };

    static CpuTimes              readCpuTimes();
    static double                readMemUsage(double &totalGB, double &freeGB);
    static double                readLoadAvg();
    static QMap<QString,NetBytes> readNetBytes();
    static QVariantList          toVL(const QVector<double> &v);
    static void                  push(QVector<double> &v, double val);

    QTimer        m_timer;
    QElapsedTimer m_elapsed;

    CpuTimes              m_lastCpu;
    QMap<QString,NetBytes> m_lastNet;

    double m_cpuUsage    = 0;
    double m_memUsage    = 0;
    double m_loadAvg     = 0;
    double m_totalMemGB  = 0;
    double m_freeMemGB   = 0;
    double m_wiredUp     = 0;
    double m_wiredDown   = 0;
    double m_hotspotUp   = 0;
    double m_hotspotDown = 0;

    QVector<double> m_wiredDownH,   m_wiredUpH;
    QVector<double> m_hotspotDownH, m_hotspotUpH;
};
