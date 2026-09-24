#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "SystemMonitor.h"
#include "WeatherModel.h"
#include "WakeClient.h"
#include "CalendarModel.h"
#include <QCommandLineParser>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);
    app.setApplicationName("Nexus");
    app.setOrganizationName("Nexus");
    app.setApplicationVersion(QStringLiteral(NEXUS_VERSION));
    QCommandLineParser parser;
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addOption({"fullscreen", "Run in fullscreen mode"});
    parser.process(app);

    // 所有功能均在本地运行，无需外部服务器
    SystemMonitor sysMonitor;
    WeatherModel  weatherModel;
    WakeClient    wakeClient;
    CalendarModel calendarModel;

    sysMonitor.start();
    weatherModel.fetchWeather();

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("sysMonitor",   &sysMonitor);
    engine.rootContext()->setContextProperty("weatherModel", &weatherModel);
    engine.rootContext()->setContextProperty("wakeClient",   &wakeClient);
    engine.rootContext()->setContextProperty("calendarModel", &calendarModel);

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl) QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
