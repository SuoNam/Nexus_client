#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QQuickItem>
#include <QJSValue>
#include <QJsonDocument>
#include <QJsonArray>
#include <QTest>
#include <QFile>
#include <cstdio>
#include <cstdlib>

// Run with an isolated XDG_CONFIG_HOME; never point this test at user settings.
int main(int argc, char **argv) {
    QGuiApplication app(argc, argv);
    app.setOrganizationName("Nexus");
    app.setApplicationName("Nexus");
    if (argc != 4) return 2;
    QQmlApplicationEngine engine;
    const QString qml = "import QtQuick 2.15\nimport QtQuick.Controls 2.15\n"
        "import \"" + QUrl::fromLocalFile(QString::fromLocal8Bit(argv[1])).toString() + "\"\n"
        "ApplicationWindow { width: 1280; height: 720; visible: true; "
        "CountdownBanner { objectName: 'banner'; width: 1200 } }";
    engine.loadData(qml.toUtf8());
    if (engine.rootObjects().isEmpty()) return 3;
    auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
    auto *banner = window->findChild<QQuickItem *>("banner");
    QTest::qWait(80);
    const QString mode = QString::fromLocal8Bit(argv[2]);
    if (mode == "delete") {
        // Actual first-row delete button, using its stable layout geometry.
        QTest::mouseClick(window, Qt::LeftButton, Qt::NoModifier, QPoint(1176, 20));
    } else if (mode == "save") {
        const QJSValue items = engine.evaluate(QString::fromUtf8(argv[3]));
        if (!QMetaObject::invokeMethod(banner, "saveItems", Q_ARG(QVariant, QVariant::fromValue(items)))) return 4;
    }
    const auto value = banner->property("cdItems").value<QJSValue>().toVariant();
    const auto json = QJsonDocument(QJsonArray::fromVariantList(value.toList())).toJson(QJsonDocument::Compact);
    fprintf(stdout, "%s\n", json.constData());
    fflush(stdout);
    if (mode == "check") {
        const auto expected = QJsonDocument::fromJson(QByteArray(argv[3]));
        return QJsonDocument::fromJson(json) == expected ? 0 : 5;
    }
    // No event-loop grace period and no destructors: model abrupt process termination.
    std::_Exit(0);
}
