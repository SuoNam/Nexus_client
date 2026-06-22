#pragma once
#include <QObject>
#include <QNetworkAccessManager>
#include <QTimer>
#include <QVariantMap>

// 直接调用 QWeather API，不再经过本地 Python 服务端
class WeatherModel : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantMap today    READ today    NOTIFY weatherChanged)
    Q_PROPERTY(QVariantMap tomorrow READ tomorrow NOTIFY weatherChanged)
    Q_PROPERTY(bool loading         READ loading  NOTIFY loadingChanged)

public:
    explicit WeatherModel(QObject *parent = nullptr);

    // serverBase 参数保留兼容性，实际不再使用
    void fetchWeather(const QString & /*unused*/ = QString()) { startFetch(); }

    QVariantMap today()    const { return m_today; }
    QVariantMap tomorrow() const { return m_tomorrow; }
    bool loading()         const { return m_loading; }

signals:
    void weatherChanged();
    void loadingChanged();

private:
    static const QString API_KEY;
    static const QString API_HOST;

    void startFetch();
    void fetchForCity(const QString &cityName);
    void fetchForecast(const QString &locationId);

    QNetworkAccessManager m_nam;
    QTimer                m_refreshTimer;
    bool                  m_loading = false;
    QVariantMap           m_today;
    QVariantMap           m_tomorrow;
};
