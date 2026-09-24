#include "CalendarModel.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDateTime>
#include <QLocale>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QDebug>

CalendarModel::CalendarModel(QObject *parent) : QObject(parent) {
    QFile file(QStringLiteral(":/data/calendar-2026.json"));
    if (file.open(QIODevice::ReadOnly)) {
        auto data = QJsonDocument::fromJson(file.readAll()).object();
        m_year = data["year"].toInt();
        m_calendars = data["calendars"].toObject();
    }
    connect(&m_clock, &QTimer::timeout, this, &CalendarModel::update);
    connect(&m_refresh, &QTimer::timeout, this, [this] { locate(); });
    m_clock.start(1000);
    m_refresh.setSingleShot(true);
    update();
    QTimer::singleShot(0, this, [this] { locate(); });
}

void CalendarModel::update() {
    const auto now = QDateTime::currentDateTimeUtc().toTimeZone(m_zone);
    m_time = now.toString("HH:mm:ss");
    m_date = QLocale(QLocale::Chinese, QLocale::China).toString(now.date(), "yyyy年M月d日 dddd");
    m_holiday = false;
    if (m_failed) m_status = QStringLiteral("地区信息暂不可用，稍后重试");
    else if (m_located) {
        if (now.date().year() != m_year || !m_calendars.contains(m_key)) {
            m_status = QStringLiteral("当地节假日数据暂不可用");
        } else {
            auto day = m_calendars[m_key].toObject()[now.date().toString(Qt::ISODate)].toArray();
            const auto kind = day.isEmpty() ? QStringLiteral("workday") : day[0].toString();
            m_holiday = kind == "holiday";
            if (m_holiday) m_status = QStringLiteral("节假日 · ") + day[1].toString();
            else if (kind == "makeup") m_status = QStringLiteral("调休补班 · 今天是工作日");
            else if (kind == "weekend") m_status = QStringLiteral("周末 · 休息日");
            else m_status = QStringLiteral("今天是工作日");
        }
    }
    emit changed();
}

void CalendarModel::locate(bool fallback) {
    if (m_pending) return;
    m_pending = true;
    QNetworkRequest request(QUrl(fallback ? "https://ipapi.co/json/" : "https://ipwho.is/"));
    request.setTransferTimeout(8000);
    auto *reply = m_network.get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply, fallback] {
        reply->deleteLater();
        m_pending = false;
        const auto data = QJsonDocument::fromJson(reply->readAll()).object();
        const auto zoneName = fallback ? data["timezone"].toString() : data["timezone"].toObject()["id"].toString();
        const QTimeZone zone(zoneName.toUtf8());
        const auto country = data["country_code"].toString();
        const bool success = fallback ? !data["error"].toBool() : data["success"].toBool();
        if (reply->error() == QNetworkReply::NoError && success && zone.isValid() && country.size() == 2) {
            m_zone = zone;
            const auto regional = country + "/" + data["region_code"].toString();
            m_key = m_calendars.contains(regional) ? regional : country;
            m_location = (fallback ? data["country_name"].toString() : data["country"].toString())
                + " · " + data["region"].toString()
                + (m_key == country ? QStringLiteral(" · 全国节假日") : QStringLiteral(" · 当地节假日"));
            m_located = true;
            m_failed = false;
            m_refresh.start(30 * 60 * 1000);
            qInfo() << "Calendar location:" << country << zoneName << "calendar:" << m_key;
        } else if (!fallback) {
            locate(true);
            return;
        } else {
            m_failed = true;
            m_refresh.start(5 * 60 * 1000);
            qWarning() << "Calendar IP location unavailable; retry in five minutes";
        }
        update();
    });
}
