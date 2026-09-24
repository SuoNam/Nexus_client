#pragma once
#include <QObject>
#include <QNetworkAccessManager>
#include <QTimeZone>
#include <QTimer>
#include <QJsonObject>

class CalendarModel : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString time READ time NOTIFY changed)
    Q_PROPERTY(QString date READ date NOTIFY changed)
    Q_PROPERTY(QString status READ status NOTIFY changed)
    Q_PROPERTY(QString location READ location NOTIFY changed)
    Q_PROPERTY(bool holiday READ holiday NOTIFY changed)
public:
    explicit CalendarModel(QObject *parent = nullptr);
    QString time() const { return m_time; }
    QString date() const { return m_date; }
    QString status() const { return m_status; }
    QString location() const { return m_location; }
    bool holiday() const { return m_holiday; }
signals:
    void changed();
private:
    void update();
    void locate(bool fallback = false);
    QNetworkAccessManager m_network;
    QTimer m_clock, m_refresh;
    QTimeZone m_zone = QTimeZone::systemTimeZone();
    QJsonObject m_calendars;
    int m_year = 0;
    QString m_time, m_date, m_status = QStringLiteral("正在获取当地节假日…");
    QString m_location = QStringLiteral("设备本地时间"), m_key;
    bool m_located = false, m_failed = false, m_pending = false, m_holiday = false;
};
