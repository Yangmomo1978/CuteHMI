import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.4

import CuteHMI.Modbus 2.0

Control {
	padding: 20
	contentItem: ColumnLayout {
		spacing: 10

		RowLayout {
			Layout.alignment: Qt.AlignLeft

			Label {
				text: qsTr("Device type:")
			}

			ComboBox {
				textRole: "name"

				model: ListModel {
					ListElement { name: "DummyClient"; source: "DummyClientComposite.qml"}
				}

				onActivated: loader.source = model.get(currentIndex).source
			}
		}

		Loader {
			id: loader

			source: "DummyClientComposite.qml"
		}
	}

	property alias source: loader.source
}

//(c)C: Copyright © 2019, Michał Policht <michal@policht.pl>. All rights reserved.
//(c)C: This file is a part of CuteHMI.
//(c)C: CuteHMI is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//(c)C: CuteHMI is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.
//(c)C: You should have received a copy of the GNU Lesser General Public License along with CuteHMI.  If not, see <https://www.gnu.org/licenses/>.
