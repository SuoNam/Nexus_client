#include "WeatherModel.h"
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDate>
#include <QUrlQuery>

const QString WeatherModel::API_KEY  = "02aedfbd47a7459384722a79c55b2457";
const QString WeatherModel::API_HOST = "https://jw6r722k8d.re.qweatherapi.com";

WeatherModel::WeatherModel(QObject *parent) : QObject(parent)
{
    m_refreshTimer.setInterval(30 * 60 * 1000);  // 30 min
    connect(&m_refreshTimer, &QTimer::timeout, this, &WeatherModel::startFetch);
}

void WeatherModel::startFetch()
{
    if (m_loading) return;
    m_loading = true;
    emit loadingChanged();

    // Step 1：用盒子自身公网 IP 获取城市（不传 IP，ip-api.com 自动识别）
    auto *reply = m_nam.get(QNetworkRequest(QUrl("http://ip-api.com/json/?lang=zh-CN")));
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        QString city = "大连";  // 兜底城市

        if (reply->error() == QNetworkReply::NoError) {
            auto obj = QJsonDocument::fromJson(reply->readAll()).object();
            if (obj["status"].toString() == "success") {
                QString c = obj["city"].toString();
                if (!c.isEmpty()) city = c.remove("市");
            }
        }
        fetchForCity(city);
    });
}

void WeatherModel::fetchForCity(const QString &cityName)
{
    // Step 2：城市名 → Location ID
    QUrl geoUrl(API_HOST + "/geo/v2/city/lookup");
    QUrlQuery q;
    q.addQueryItem("location", cityName);
    geoUrl.setQuery(q);

    QNetworkRequest req(geoUrl);
    req.setRawHeader("X-QW-Api-Key", API_KEY.toUtf8());

    auto *reply = m_nam.get(req);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        QString locationId = "101070201";  // 兜底：大连

        if (reply->error() == QNetworkReply::NoError) {
            auto obj = QJsonDocument::fromJson(reply->readAll()).object();
            if (obj["code"].toString() == "200") {
                auto locs = obj["location"].toArray();
                if (!locs.isEmpty())
                    locationId = locs[0].toObject()["id"].toString();
            }
        }
        fetchForecast(locationId);
    });
}

void WeatherModel::fetchForecast(const QString &locationId)
{
    // Step 3：7 天预报
    QUrl url(API_HOST + "/v7/weather/7d");
    QUrlQuery q;
    q.addQueryItem("location", locationId);
    url.setQuery(q);

    QNetworkRequest req(url);
    req.setRawHeader("X-QW-Api-Key", API_KEY.toUtf8());

    auto *reply = m_nam.get(req);
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        reply->deleteLater();
        m_loading = false;
        emit loadingChanged();

        if (reply->error() != QNetworkReply::NoError) return;

        auto obj = QJsonDocument::fromJson(reply->readAll()).object();
        if (obj["code"].toString() != "200") return;

        const QJsonArray daily  = obj["daily"].toArray();
        const QString    today  = QDate::currentDate().toString("yyyy-MM-dd");
        const QString    tmr    = QDate::currentDate().addDays(1).toString("yyyy-MM-dd");

        auto extract = [](const QJsonObject &d, const QString &lbl) -> QVariantMap {
            return {
                {"label",      lbl},
                {"date",       d["fxDate"].toString()},
                {"text",       d["textDay"].toString()},
                {"tempMax",    d["tempMax"].toString()},
                {"tempMin",    d["tempMin"].toString()},
                {"windDir",    d["windDirDay"].toString()},
                {"windScale",  d["windScaleDay"].toString()},
                {"iconDay",    d["iconDay"].toString()},
            };
        };

        for (const auto &v : daily) {
            auto d = v.toObject();
            if (d["fxDate"].toString() == today)
                m_today = extract(d, "今天");
            else if (d["fxDate"].toString() == tmr)
                m_tomorrow = extract(d, "明天");
        }
        emit weatherChanged();

        if (!m_refreshTimer.isActive()) m_refreshTimer.start();
    });
}
