#include "WakeClient.h"

#ifdef HAS_SERIAL_PORT
#  include <QtSerialPort/QSerialPort>
#else
#  include <QProcess>
#endif

WakeClient::WakeClient(QObject *parent) : QObject(parent) {}

void WakeClient::wake(const QString &)
{
    const QString port = qEnvironmentVariable("NEXUS_SERIAL_PORT", "/dev/ttyUSB0");

#ifdef HAS_SERIAL_PORT
    QSerialPort serial;
    serial.setPortName(port);
    serial.setBaudRate(QSerialPort::Baud9600);
    serial.setDataBits(QSerialPort::Data8);
    serial.setParity(QSerialPort::NoParity);
    serial.setStopBits(QSerialPort::OneStop);
    serial.setFlowControl(QSerialPort::NoFlowControl);

    if (!serial.open(QIODevice::WriteOnly)) {
        emit wakeResult(false, "串口打开失败: " + serial.errorString());
        return;
    }
    serial.write("W");
    serial.flush();
    serial.close();
    emit wakeResult(true, "唤醒指令已发送");

#else
    // 兜底：用 shell 写串口（开发机或未安装 SerialPort 时）
    QProcess proc;
    proc.start("bash", {"-c", "printf 'W' > " + port});
    if (proc.waitForFinished(2000) && proc.exitCode() == 0) {
        emit wakeResult(true, "唤醒指令已发送");
    } else {
        emit wakeResult(false, "串口写入失败（" + proc.errorString() + "）");
    }
#endif
}
