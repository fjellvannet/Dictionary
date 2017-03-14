/****************************************************************************
**
** Copyright (C) 2015 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Window 2.1
import QtQuick.Controls.Material 2.1

Window {
    visible: true

    Material.theme: Material.Light
    Material.accent: Material.Blue
    y: (Screen.height - height) / 2
    x: (Screen.width - width) / 2
    height: windowColumn.height
    width: windowColumn.width
    color: "white"
    title: "Splash Window"
    flags: Qt.SplashScreen
    modality: Qt.WindowModal
    property int basicUnit: splashImage.width / sizeConstant
    property int sizeConstant: 30

    Text {id: stdText}

    Column{
        id: windowColumn
        anchors.centerIn: parent
        spacing: basicUnit
        AdaptedImage {
            id: splashImage
            height: width
            width: Math.min(Math.min(Screen.height, Screen.width)/2, sizeConstant*stdText.font.pixelSize)
            source: "qrc:/images/icons/app_icon"
            MouseArea {
                anchors.fill: parent
                onClicked: Qt.quit()
            }
        }
        ProgressBar {
            height: 2*basicUnit
            background.height: height
            contentItem.implicitHeight: height
            width: parent.width
            indeterminate: true
        }
        Text{
            text: Qt.application.name
            width: splashImage.width
            font.bold: true
            font.pixelSize: {
                var patt = / /
                if(patt.test(text)) return 4*basicUnit
                else return 3*basicUnit
            }
            maximumLineCount: 2
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
