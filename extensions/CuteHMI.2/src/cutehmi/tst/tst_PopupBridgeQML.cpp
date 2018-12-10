#include <cutehmi/PopupBridge.hpp>

#include <QtQuickTest>
#include <QQmlEngine>
#include <QQmlContext>

class Setup:
	public QObject
{
	Q_OBJECT

	public slots:
		void applicationAvailable()
		{
			m_popupBridge.reset(new cutehmi::PopupBridge);
		}

		void qmlEngineAvailable(QQmlEngine * engine)
		{
			engine->rootContext()->setContextProperty("popupBridge", m_popupBridge.get());
		}

		void cleanupTestCase()
		{
		}

	private:
		std::unique_ptr<cutehmi::PopupBridge> m_popupBridge;
};

QUICK_TEST_MAIN_WITH_SETUP(CuteHMI.2, Setup)
#include "tst_PopupBridgeQML.moc"