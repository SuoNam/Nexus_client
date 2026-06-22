#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "SystemMonitor.h"
#include "WeatherModel.h"
#include "WakeClient.h"

int main(int argc, char *argv[])
{
    // Qt6 handles HighDpiScaling natively, no need for the deprecated attribute
    QGuiApplication app(argc, argv);
    app.setApplicationName("Nexus");
    app.setOrganizationName("Nexus");

    // 所有功能均在本地运行，无需外部服务器
    SystemMonitor sysMonitor;
    WeatherModel  weatherModel;
    WakeClient    wakeClient;

    sysMonitor.start();
    weatherModel.fetchWeather();

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("sysMonitor",   &sysMonitor);
    engine.rootContext()->setContextProperty("weatherModel", &weatherModel);
    engine.rootContext()->setContextProperty("wakeClient",   &wakeClient);

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl) QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
