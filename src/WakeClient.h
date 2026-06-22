#pragma once
#include <QObject>

// 通过 QSerialPort 直接写串口唤醒设备
class WakeClient : public QObject {
    Q_OBJECT
public:
    explicit WakeClient(QObject *parent = nullptr);

    // 串口设备路径，默认 /dev/ttyUSB0，可通过环境变量 NEXUS_SERIAL_PORT 覆盖
    Q_INVOKABLE void wake(const QString & /*unused*/ = QString());

signals:
    void wakeResult(bool success, const QString &message);
};
