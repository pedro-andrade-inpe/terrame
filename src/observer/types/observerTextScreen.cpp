#include "observerTextScreen.h"

#include <QApplication>
#include <QByteArray>

#include "visualArrangement.h"

ObserverTextScreen::ObserverTextScreen(Subject *subj, QWidget *parent)
    : QDialog(parent), ObserverInterf(subj), QThread()
{
    observerType = TObsTextScreen;
    subjectType = TObsUnknown;

    paused = false;
    header = false;

    setWindowTitle("Text Screen");

    textEdit = new QTextEdit(this);
    textEdit->setReadOnly(true);

    VisualArrangement::getInstance()->starts(getId(), this);

    textEdit->setFixedSize(this->size());

    start(QThread::IdlePriority);
}

ObserverTextScreen::~ObserverTextScreen()
{
    wait();
}

const TypesOfObservers ObserverTextScreen::getType()
{
    return observerType;
}

bool ObserverTextScreen::draw(QDataStream &state)
{
    QString msg;
    state >> msg;
    QStringList tokens = msg.split(PROTOCOL_SEPARATOR);

    //double num;
    //QString text;
    //bool b;

    //QString subjectId = tokens.at(0);
    //int subType = tokens.at(1).toInt();
    int qtdParametros = tokens.at(2).toInt();
    //int nroElems = tokens.at(3).toInt();
    int j = 4;

    for (int i=0; i < qtdParametros; i++)
    {
        QString key = tokens.at(j);
        j++;
        int typeOfData = tokens.at(j).toInt();
        j++;

        bool contains = attribList.contains(key);

        switch (typeOfData)
        {
            case (TObsBool)		:
                if (contains)
                    valuesList.replace(attribList.indexOf(key),
                                       (tokens.at(j).toInt() ? "true" : "false"));
                break;

            case (TObsDateTime)	:
                //break;

            case (TObsNumber)		:
                if (contains)
                    valuesList.replace(attribList.indexOf(key), tokens.at(j));
                break;

            default							:
                if (contains)
                    valuesList.replace(attribList.indexOf(key), tokens.at(j));
                break;
        }
        j++;
    }

    qApp->processEvents();
    return write();
}

void ObserverTextScreen::setAttributes(QStringList &attribs)
{
    attribList = attribs;
    for (int i = 0; i < attribList.size(); i++)
        valuesList.insert(i, QString("")); // lista dos itens na ordem em que aparecem
    header = false;
}

bool ObserverTextScreen::headerDefined()
{
    return header;
}

bool ObserverTextScreen::write()
{
    // insere o cabe?alho do arquivo
    if (! header)
    {
        QString headers;
        for (int i = 0; i < attribList.size(); ++i)
        {
            headers += attribList.at(i);

            if (i < attribList.size() - 1)
                headers += "\t";
        }

        textEdit->setText(headers);
        header = true;
    }

    QString text;
    for (int i = 0; i < valuesList.size(); i++)
    {
        text += valuesList.at(i) + "\t";

        if (i < valuesList.size() - 1)
            text += "\t";
    }

    textEdit->append(text);

    return true;
}

void ObserverTextScreen::run()
{
    //while (!paused)
    //{
    //    QThread::exec();
    //    //show();
    //    //printf("run() ");
    //}
    QThread::exec();
}

void ObserverTextScreen::pause()
{
    paused = !paused;
}

QStringList ObserverTextScreen::getAttributes()
{
    return attribList;
}

int ObserverTextScreen::close()
{
    QThread::exit(0);
    return 0;
}

void ObserverTextScreen::resizeEvent(QResizeEvent *event)
{
    VisualArrangement::getInstance()->resizeEventDelegate(getId(), event);
    textEdit->setFixedSize(this->size());
}

void ObserverTextScreen::moveEvent(QMoveEvent *event)
{
    VisualArrangement::getInstance()->moveEventDelegate(getId(), event);
}

void ObserverTextScreen::closeEvent(QCloseEvent *event)
{
    VisualArrangement::getInstance()->closeEventDelegate();
}

void ObserverTextScreen::save(std::string file, std::string extension)
{
      saveAsImage(file, extension);
}

void ObserverTextScreen::saveAsImage(std::string file, std::string extension)
{
      QPixmap pixmap = textEdit->grab();
      pixmap.save(file.c_str(), extension.c_str());
}

