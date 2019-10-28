import qbs
import qbs.FileInfo
import qbs.Environment
import qbs.Utilities
import qbs.File
import qbs.TextFile

/**
  This module generates 'qmldir' artifact. The syntax of 'qmldir' files is described
  [here](https://doc.qt.io/qt-5/qtqml-modules-qmldir.html).
  */
Module {
	additionalProductTypes: ["qmldir"]

	/**
	  Whether to modify '.gitignore' file. Setting this property to @p true will result in adding a rule to ignore 'qmldir' files.
	  Note that '.gitignore' itself is not treated as an artifact. This means it will be modified only when generation of 'qmldir'
	  artifact is triggered.
	  */
	property bool modifyGitignore: true

	/**
	  Module identifier. By default product base name is used.
	  */
	property string moduleIdentifier: product.baseName

	/**
	  Initial major version. The property represents major version of \<InitialVersion\>, that stands after \<TypeName\> of each QML
	  type entry. By default the property is binded to major version of a product.
	  */
	property int major: product.major

	/**
	  Initial minor version. The property represents minor version of \<InitialVersion\>, that stands after \<TypeName\> of each QML
	  type entry. Default value is @p 0.
	  */
	property int minor: 0

	/**
	  Plugin name. This property stands for `<Name>` in 'qmldir' entry `plugin <Name> [<Path>]`.
	  */
	property string pluginName: product.baseName

	/**
	  Plugin directory. A place where plugin library resides. Plugin directory is specified as relative to the location of 'qmldir'
	  file. This property stands for `<Path>` in 'qmldir' entry `plugin <Name> [<Path>]`.
	  */
	property string pluginDir: FileInfo.relativePath(product.sourceDirectory, cutehmi.dirs.extensionsSourceDir)

	/**
	  Name of plugin class header. If file with given pattern is present in product file list, then `plugin` and `classname` entries
	  will be generated. Additionaly product type must contain `dynamiclibrary`.
	  */
	property string qmlPluginClassHeader: "QMLPlugin.hpp"

	/**
	  Plugin class name. Default class name is fabricated out of product base name converted into a namespace and
	  `::internal::QMLPlugin` suffix.
	  */
	property string className: product.baseName.toLowerCase().replace(/\./g, '::') + "::internal::QMLPlugin"

	/**
	  Name of type description file.
	  */
	property string typeInfo: "plugins.qmltypes"

	/**
	  Whether Qt Quick Designer is supported by the plugin.
	  */
	property bool designerSupported: true

	/**
	  Additional entries. Array containing additional entries that should be written to 'qmldir' file.
	  */
	property var additionalEntries: []

	/**
	  Files map. This property can be used to override default-generated type entries of QML and Javascript files. The syntax of
	  these entries is described
	  [here](https://doc.qt.io/qt-5/qtqml-modules-qmldir.html#contents-of-a-module-definition-qmldir-file).
	  A Javascript object should be assigned to this property, where keys denote file names and values contain type definitions.
	  For example, to get folllowing entries in 'qmldir' file:
	  @code
	  Boletus 4.7 Boletus.qml
	  singleton MagicMushroom 4.4 MagicMushroom.qml
	  @endcode
	  , set the property to the following:
	  @code
	  cutehmi.qmldir.filesMap: ({"Boletus.qml": "Boletus 4.7", "MagicMushroom.qml": "singleton MagicMushroom 4.4"})
	  @endcode
	  .
	  */
	property var filesMap: ({})

	Depends { name: "cutehmi.dirs" }

	FileTagger {
		patterns: ["*.qbs"]
		fileTags: ["qbs"]
	}

	FileTagger {
		patterns: ["*.qml"]
		fileTags: ["qml"]
	}

	FileTagger {
		patterns: [qmlPluginClassHeader]
		fileTags: ["cutehmi.qmldir.qmlPlugin"]
	}

	Rule {
		inputs: ["qbs", "qml", "js", "cutehmi.qmldir.qmlPlugin"]
		multiplex: true

		prepare: {
			var qmldirCmd = new JavaScriptCommand();
			qmldirCmd.description = 'generating ' + product.sourceDirectory + '/qmldir'
			qmldirCmd.highlight = 'codegen';
			qmldirCmd.sourceCode = function() {
				var f = new TextFile(product.sourceDirectory + "/qmldir", TextFile.WriteOnly);
				try {
					f.writeLine("# This file has been autogenerated by Qbs cutehmi.qmldir module.")
					f.writeLine("");

					f.writeLine("module " + product.cutehmi.qmldir.moduleIdentifier)

					if (inputs.qml !== undefined) {
						f.writeLine("")
						for (var i = 0; i < inputs.qml.length; i++)
							if (product.cutehmi.qmldir.filesMap[inputs.qml[i].fileName] !== undefined)
								f.writeLine(product.cutehmi.qmldir.filesMap[inputs.qml[i].fileName] + " " + inputs.qml[i].fileName)
							else
								f.writeLine(inputs.qml[i].baseName + " " + product.cutehmi.qmldir.major + "." + product.cutehmi.qmldir.minor + " " + inputs.qml[i].fileName)
					}

					if (inputs.js !== undefined) {
						f.writeLine("")
						for (var i = 0; i < inputs.js.length; i++)
							if (product.cutehmi.qmldir.filesMap[inputs.js[i].fileName] !== undefined)
								f.writeLine(product.cutehmi.qmldir.filesMap[inputs.js[i].fileName] + " " + inputs.js[i].fileName)
							else
								f.writeLine(inputs.js[i].baseName + " " + product.cutehmi.qmldir.major + "." + product.cutehmi.qmldir.minor + " " + inputs.js[i].fileName)
					}

					if (product.type.contains("dynamiclibrary") && inputs["cutehmi.qmldir.qmlPlugin"] !== undefined) {
						f.writeLine("")
						f.writeLine("plugin " + product.cutehmi.qmldir.pluginName + " " + product.cutehmi.qmldir.pluginDir)
						f.writeLine("classname " + product.cutehmi.qmldir.className)
					}

					if (product.cutehmi.qmldir.typeInfo !== undefined) {
						f.writeLine("")
						f.writeLine("typeinfo " +  product.cutehmi.qmldir.typeInfo)
					}

					if (product.cutehmi.qmldir.designerSupported) {
						f.writeLine("")
						f.writeLine("designersupported")
					}

					if (product.cutehmi.qmldir.additionalEntries.length > 0)
						f.writeLine("")
					for (var i = 0; i < product.cutehmi.qmldir.additionalEntries.length; i++)
						f.writeLine(product.cutehmi.qmldir.additionalEntries[i])
				} finally {
					f.close()
				}
			}

			var gitignoreCmd = new JavaScriptCommand();
			gitignoreCmd.description = 'generating ' + product.sourceDirectory + '/.gitignore'
			gitignoreCmd.highlight = 'codegen';
			gitignoreCmd.sourceCode = function() {
				var f = new TextFile(product.sourceDirectory + "/.gitignore", TextFile.ReadWrite);
				var qmldirLinePresent = false
				try {
					var empty = false
					if (f.atEof())
						empty = true

					while (!f.atEof())
						if (f.readLine() == "qmldir")
							qmldirLinePresent = true

					if (!qmldirLinePresent) {
						if (!empty)
							f.writeLine("")
						f.writeLine("# Ignore 'qmldir' files (entry added by Qbs cutehmi.qmldir module).")
						f.writeLine("qmldir");
					}
				} finally {
					f.close()
				}
			}

			if (product.cutehmi.qmldir.modifyGitignore)
				return [qmldirCmd, gitignoreCmd]
			else
				return [qmldirCmd]
		}

		Artifact {
			filePath: product.sourceDirectory + "/qmldir"
			fileTags: ["qmldir"]
		}
	}
}

//(c)C: Copyright © 2019, Michal Policht <michpolicht@gmail.com>, Mr CuteBOT <michpolicht@gmail.com>. All rights reserved.
//(c)C: This file is a part of CuteHMI.
//(c)C: CuteHMI is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//(c)C: CuteHMI is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.
//(c)C: You should have received a copy of the GNU Lesser General Public License along with CuteHMI.  If not, see <https://www.gnu.org/licenses/>.
