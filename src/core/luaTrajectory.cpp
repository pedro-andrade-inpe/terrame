#include "luaTrajectory.h"

#include "observerTextScreen.h"
#include "observerGraphic.h"
#include "observerLogFile.h"
#include "observerTable.h"
#include "observerUDPSender.h"
#include "agentObserverMap.h"
#include "agentObserverImage.h"

#include "luaCellularSpace.h"
#include "luaUtils.h"
#include "terrameGlobals.h"

#ifdef TME_PROTOCOL_BUFFERS
	#include "protocol.pb.h"
#endif

extern ExecutionModes execModes;

luaTrajectory::luaTrajectory(lua_State* L)
{
    // Antonio
    subjectType = TObsTrajectory;
    luaL = L;
    cellSpace = 0;
    observedAttribs.clear();
}

luaTrajectory::~luaTrajectory(void)
{
    luaRegion::clear();
}

int luaTrajectory::add(lua_State* L)
{
    int i = luaL_checknumber(L, -2);
    luaCell *cell = (luaCell*)Luna<luaCell>::check(L, -1);
    CellIndex idx;
    idx.first = i;
    idx.second = 0;
    luaRegion::add(idx, cell);

    return 0;
}

int luaTrajectory::clear(lua_State *)
{
    luaRegion::clear();
    return 0;
}

int luaTrajectory::createObserver(lua_State *L)
{
    // retrieve the reference of the cell
    Reference<luaTrajectory>::getReference(luaL);

    // flags for the definition of the use of compression
    // in the datagram transmission and visibility
    // of observers Udp Sender
    bool compressDatagram = false, obsVisible = true;

    // retrieve the attribute table of the cell
    int top = lua_gettop(luaL);

    // In no way changes the stack
    // retrieves the enum for the type
    // of observer
    int typeObserver = (int)luaL_checkinteger(luaL, 1);

    if ((typeObserver !=  TObsMap) && (typeObserver !=  TObsImage))
    {
        QStringList allAttribs, obsAttribs, obsParams, cols;

        // qDebug() << "Retrieves the parameters table";
        lua_pushnil(luaL);
        while(lua_next(luaL, top - 1) != 0)
        {
            QString key;

            if (lua_type(luaL, -2) == LUA_TSTRING)
            {
                key = luaL_checkstring(luaL, -2);
            }
            //else
            //{
            //    if (lua_type(luaL, -2) == LUA_TNUMBER)
            //    {
            //        char aux[100];
            //        double number = luaL_checknumber(luaL, -2);
            //        sprintf(aux, "%g", number);
            //        key = aux;
            //    }
            //}

            switch (lua_type(luaL, -1))
            {
            case LUA_TBOOLEAN:
                {
                    bool val = lua_toboolean(luaL, -1);
                    if (key == "visible")
                        obsVisible = val;
                    else // if (key == "compress")
                        compressDatagram = val;
                    break;
                }

            case LUA_TSTRING:
                {
                    const char *strAux = luaL_checkstring(luaL, -1);
                    cols.append(strAux);
                    break;
                }
            case LUA_TTABLE:
                {
                    int pos = lua_gettop(luaL);
                    QString k;

                    lua_pushnil(luaL);
                    while(lua_next(luaL, pos) != 0)
                    {

                        if (lua_type(luaL, -2) == LUA_TSTRING)
                        {
                            obsParams.append(luaL_checkstring(luaL, -2));
                        }

                        switch (lua_type(luaL, -1))
                        {
                        case LUA_TSTRING:
                            k = QString(luaL_checkstring(luaL, -1));
                            break;

                        case LUA_TNUMBER:
                            {
                                char aux[100];
                                double number = luaL_checknumber(luaL, -1);
                                sprintf(aux, "%g", number);
                                k = QString(aux);
                                break;
                            }
                        default:
                            break;
                        }
                        cols.append(k);
                        lua_pop(luaL, 1);
                    }
                    break;
                }
            default:
                break;
            }
            lua_pop(luaL, 1);
        }

        // qDebug() << "Retrieves the attribute table";
        lua_pushnil(luaL);
        while(lua_next(luaL, top - 2) != 0)
        {
            if (lua_type(luaL, -1) == LUA_TSTRING)
            {
                // QString key(luaL_checkstring(luaL, -1));
                obsAttribs.push_back(luaL_checkstring(luaL, -1));
            }
            lua_pop(luaL, 1);
        }

        // Retrieves all subject attributes
        lua_pushnil(luaL);
        while(lua_next(luaL, top) != 0)
        {
            if (lua_type(luaL, -2) == LUA_TSTRING)
                allAttribs.append(luaL_checkstring(luaL, -2));
            lua_pop(luaL, 1);
        }

        if (obsAttribs.empty())
        {
        	obsAttribs = allAttribs;
        	// observedAttribs = allAttribs;

            foreach(const QString &key, allAttribs)
                observedAttribs.insert(key, "");
        }
        else
        {
            // Checks if the given attribute really exists in the cell
            for (int i = 0; i < obsAttribs.size(); i++)
            {
                if (!observedAttribs.contains(obsAttribs.at(i)))
                    // observedAttribs.push_back(obsAttribs.at(i));
                    observedAttribs.insert(obsAttribs.at(i), "");

                if (!allAttribs.contains(obsAttribs.at(i)))
                {
					string err_out = string("Attribute name '")
							+ string (qPrintable(obsAttribs.at(i)))
							+ string("' not found.");
					lua_getglobal(L, "customError");
					lua_pushstring(L, err_out.c_str());
					//lua_pushnumber(L, 5);
					lua_call(L, 1, 0);
                    return 0;
                }
            }
        }

		ObserverTextScreen *obsText = 0;
		ObserverTable *obsTable = 0;
		ObserverGraphic *obsGraphic = 0;
		ObserverLogFile *obsLog = 0;
        ObserverUDPSender *obsUDPSender = 0;
        int obsId = -1;

        switch (typeObserver)
        {
        case TObsTextScreen:
            obsText = (ObserverTextScreen*)
                TrajectorySubjectInterf::createObserver(TObsTextScreen);
            if (obsText)
            {
                obsId = obsText->getId();
            }
            else
            {
                if (execModes != Quiet)
                    qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
            }
            break;

        case TObsLogFile:
            obsLog = (ObserverLogFile*)
                TrajectorySubjectInterf::createObserver(TObsLogFile);
            if (obsLog)
            {
                obsId = obsLog->getId();
            }
            else
            {
                if (execModes != Quiet)
                    qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
            }
            break;

        case TObsTable:
            obsTable = (ObserverTable *)
                TrajectorySubjectInterf::createObserver(TObsTable);
            if (obsTable)
            {
                obsId = obsTable->getId();
            }
            else
            {
                if (execModes != Quiet)
                    qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
            }
            break;

        case TObsDynamicGraphic:
            obsGraphic = (ObserverGraphic *)
                TrajectorySubjectInterf::createObserver(TObsDynamicGraphic);
            if (obsGraphic)
            {
                obsGraphic->setObserverType(TObsDynamicGraphic);
                obsId = obsGraphic->getId();
            }
            else
            {
                if (execModes != Quiet)
                    qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
            }
            break;

        case TObsGraphic:
            obsGraphic = (ObserverGraphic *)
                TrajectorySubjectInterf::createObserver(TObsGraphic);
            if (obsGraphic)
            {
                obsId = obsGraphic->getId();
            }
            else
            {
                if (execModes != Quiet)
                    qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
            }
            break;

        case TObsUDPSender:
            obsUDPSender = (ObserverUDPSender *)
                TrajectorySubjectInterf::createObserver(TObsUDPSender);
            if (obsUDPSender)
            {
                obsId = obsUDPSender->getId();
                obsUDPSender->setCompress(compressDatagram);

                if (obsVisible)
                    obsUDPSender->show();
            }
            else
            {
                if (execModes != Quiet)
                    qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
            }
            break;

        default:
            if (execModes != Quiet)
            {
                char str[12];
                sprintf(str, "%d", typeObserver);
                string err_out = string("In this context, the code '")
                		+ string(str)
						+ string("' does not correspond to a valid type of Observer.");
                lua_getglobal(L, "customWarning");
                lua_pushstring(L, err_out.c_str());
                //lua_pushnumber(L, 4);
                lua_call(L, 1, 0);
            }
            return 0;
        }

		if (obsLog)
		{
			obsLog->setAttributes(obsAttribs);

			if (cols.at(0).isNull() || cols.at(0).isEmpty())
			{
				if (execModes != Quiet) {
					string err_out = string("Filename was not specified, using a default '")
							+ string(DEFAULT_NAME.toStdString()) + string("'.");
					lua_getglobal(L, "customWarning");
					lua_pushstring(L, err_out.c_str());
					// lua_pushnumber(L, 4);
					lua_call(L, 1, 0);
				}
				obsLog->setFileName(DEFAULT_NAME + ".csv");
			}
			else
			{
				obsLog->setFileName(cols.at(0));
			}

			// if not defined, use the default ";"
			if ((cols.size() < 2) || cols.at(1).isNull() || cols.at(1).isEmpty())
			{
				if (execModes != Quiet) {
					string err_out = string("Separator not defined, using ';'.");
					lua_getglobal(L, "customWarning");
					lua_pushstring(L, err_out.c_str());
					//lua_pushnumber(L, 4);
					lua_call(L, 1, 0);
				}
				obsLog->setSeparator();
			}
			else
			{
				obsLog->setSeparator(cols.at(1));
			}

			lua_pushnumber(luaL, obsId);
			return 1;
		}

		if (obsText)
		{
			obsText->setAttributes(obsAttribs);
			lua_pushnumber(luaL, obsId);
			return 1;
		}

		if (obsTable)
		{
			if ((cols.size() < 2) || cols.at(0).isNull() || cols.at(0).isEmpty()
					|| cols.at(1).isNull() || cols.at(1).isEmpty())
			{
				if (execModes != Quiet) {
					string err_out = string("Column title not defined.");
					lua_getglobal(L, "customWarning");
					lua_pushstring(L, err_out.c_str());
					//lua_pushnumber(L, 4);
					lua_call(L, 1, 0);
				}
			}

			obsTable->setColumnHeaders(cols);
			obsTable->setAttributes(obsAttribs);

			lua_pushnumber(luaL, obsId);
			return 1;
		}

		if (obsGraphic)
		{
			obsGraphic->setLegendPosition();

			// Takes titles of three first locations
			obsGraphic->setTitles(cols.at(0), cols.at(1), cols.at(2));
			cols.removeFirst(); // remove graphic title
			cols.removeFirst(); // remove axis x title
			cols.removeFirst(); // remove axis y title

			// Splits the attribute labels in the cols list
			obsGraphic->setAttributes(obsAttribs, cols.takeFirst()
					.split(";", QString::SkipEmptyParts),
					obsParams, cols);

			lua_pushnumber(luaL, obsId);
			return 1;
		}

		if(obsUDPSender)
		{
			obsUDPSender->setAttributes(obsAttribs);

			// if (cols.at(0).isEmpty())
			if (cols.isEmpty())
			{
				if (execModes != Quiet) {
					string err_out = string("Port not defined.");
					lua_getglobal(L, "customWarning");
					lua_pushstring(L, err_out.c_str());
					//lua_pushnumber(L, 4);
					lua_call(L, 1, 0);
				}
			}
			else
			{
				obsUDPSender->setPort(cols.at(0).toInt());
			}

			// broadcast
			if ((cols.size() == 1) || ((cols.size() == 2) && cols.at(1).isEmpty()))
			{
				obsUDPSender->addHost(BROADCAST_HOST);
			}
			else
			{
				// multicast or unicast
				for(int i = 1; i < cols.size(); i++)
				{
					if (!cols.at(i).isEmpty())
						obsUDPSender->addHost(cols.at(i));
				}
			}
			lua_pushnumber(luaL, obsId);
			return 1;
		}
    }
    //   ((typeObserver !=  TObsMap) && (typeObserver !=  TObsImage))
    // Creation of spatial observers
    else
    {
    	QStringList obsParams, obsParamsAtribs; // parameters/attributes of the legend

    	bool getObserverId = false, isLegend = false;
    	int obsId = -1;

    	AgentObserverMap *obsMap = 0;
    	AgentObserverImage *obsImage = 0;

    	// Retrieves the parameters
    	lua_pushnil(luaL);
    	while(lua_next(luaL, top - 1) != 0)
    	{
    		// Retrieves the observer map ID
    		if ((lua_isnumber(luaL, -1) && (!getObserverId)))
    		{
    			obsId = luaL_checknumber(luaL, -1);
    			getObserverId = true;
    			isLegend = true;
    		}

    		// retrieves the celular space
    		if (lua_istable(luaL, -1))
    		{
    			int paramTop = lua_gettop(luaL);

    			lua_pushnil(luaL);
    			while(lua_next(luaL, paramTop) != 0)
    			{
    				if (isudatatype(luaL, -1, "TeCellularSpace"))
    				{
    					cellSpace = Luna<luaCellularSpace>::check(L, -1);
    				}
    				else
    				{
    					if (isLegend)
    					{
    						QString key = luaL_checkstring(luaL, -2);

    						obsParams.push_back(key);

    						bool boolAux;
    						double numAux;
    						QString strAux;

    						switch(lua_type(luaL, -1))
    						{
    						case LUA_TBOOLEAN:
    							boolAux = lua_toboolean(luaL, -1);
    							break;

    						case LUA_TNUMBER:
    							numAux = luaL_checknumber(luaL, -1);
    							obsParamsAtribs.push_back(QString::number(numAux));
    							break;

    						case LUA_TSTRING:
    							strAux = luaL_checkstring(luaL, -1);
    							obsParamsAtribs.push_back(QString(strAux));
    							break;

    						default:
    							break;
    						}
    					} // isLegend
    				}
    				lua_pop(luaL, 1);
    			}
    		}
    		lua_pop(luaL, 1);
    	}

    	QString errorMsg = QString("\nThe Observer ID \"%1\" was not found. "
    			"Check the declaration of this observer.\n").arg(obsId);

    	if (!cellSpace)
    	{
    		lua_getglobal(L, "customError");
    		lua_pushstring(L, errorMsg.toLatin1().data());
    		//lua_pushnumber(L, 5);
    		lua_call(L, 1, 0);
    		return 0;
    	}

    	if (typeObserver == TObsMap)
    	{
    		obsMap = (AgentObserverMap *)cellSpace->getObserver(obsId);

    		if (!obsMap)
    		{
    			lua_getglobal(L, "customError");
    			lua_pushstring(L, errorMsg.toLatin1().data());
    			//lua_pushnumber(L, 5);
    			lua_call(L, 1, 0);
    			return 0;
    		}

    		obsMap->registry(this);
    	}
    	else
    	{
    		obsImage = (AgentObserverImage *)cellSpace->getObserver(obsId);

    		if (!obsImage)
    		{
    			lua_getglobal(L, "customError");
    			lua_pushstring(L, errorMsg.toLatin1().data());
    			//lua_pushnumber(L, 5);
    			lua_call(L, 1, 0);
    			return 0;
    		}

    		obsImage->registry(this);
    	}

    	QStringList allAttribs, obsAttribs;

    	// Retrieves the attributes
    	lua_pushnil(luaL);
    	while(lua_next(luaL, top - 2) != 0)
    	{
    		const char * key = luaL_checkstring(luaL, -1);
    		obsAttribs.push_back(key);
    		lua_pop(luaL, 1);
    	}

    	for(int i = 0; i < obsAttribs.size(); i++)
    	{
    		if (!observedAttribs.contains(obsAttribs.at(i)))
    			// observedAttribs.push_back(obsAttribs.at(i));
    			observedAttribs.insert(obsAttribs.at(i), "");
    	}

    	if (typeObserver == TObsMap)
    	{
    		// to set the values of the agent attributes,
    		// redefine the type of attributes in the super class ObserverMap
    		obsMap->setAttributes(obsAttribs, obsParams, obsParamsAtribs, TObsTrajectory);
    		obsMap->setSubjectAttributes(obsAttribs, getId());
    	}
    	else
    	{
    		obsImage->setAttributes(obsAttribs, obsParams, obsParamsAtribs, TObsTrajectory);
    		obsImage->setSubjectAttributes(obsAttribs, getId());
    	}
    	lua_pushnumber(luaL, obsId);
    	return 1;
    }

    return 0;
}

const TypesOfSubjects luaTrajectory::getType() const
{
    return subjectType;
}

int luaTrajectory::notify(lua_State *L)
{
    double time = luaL_checknumber(L, -1);
    TrajectorySubjectInterf::notify(time);
    return 0;
}

#ifdef TME_BLACK_BOARD

QDataStream& luaTrajectory::getState(QDataStream& in, Subject *,
		int /*observerId*/, const QStringList & /* attribs */)
{
    int obsCurrentState = 0; //serverSession->getState(observerId);
    QByteArray content;

    switch(obsCurrentState)
	{
    case 0:
        content = getAll(in, observedAttribs.keys());
        // serverSession->setState(observerId, 1);
        // if (!QUIET_MODE)
        // qWarning(QString("Observer %1 passed to state %2").arg(observerId).arg(1).toLatin1().constData());
        break;

    case 1:
        content = getChanges(in, observedAttribs.keys());
        // serverSession->setState(observerId, 0);
        // if (!QUIET_MODE)
        // qWarning(QString("Observer %1 passed to state %2").arg(observerId).arg(0).toLatin1().constData());
        break;
	}
    // cleans the stack
    // lua_settop(L, 0);

    in << content;
    return in;
}

#else // TME_BLACK_BOARD

QDataStream& luaTrajectory::getState(QDataStream& in, Subject *,
		int observerId, const QStringList &  attribs)
{
    int obsCurrentState = 0; //serverSession->getState(observerId);
    QByteArray content;

    switch(obsCurrentState)
    {
    case 0:
        content = getAll(in, observerId, attribs);
        // serverSession->setState(observerId, 1);
        // if (execModes == Quiet)
        // qWarning(QString("Observer %1 passed to state %2").arg(observerId).arg(1).toLatin1().constData());
        break;

    case 1:
        content = getChanges(in, observerId, attribs);
        // serverSession->setState(observerId, 0);
        // if (execModes == Quiet)
        // qWarning(QString("Observer %1 passed to state %2").arg(observerId).arg(0).toLatin1().constData());
        break;
    }
    // cleans the stack
    // lua_settop(L, 0);

    in << content;
    return in;
}

#endif // TME_BLACK_BOARD

#ifdef TME_PROTOCOL_BUFFERS

QByteArray luaTrajectory::getAll(QDataStream& /*in*/, const QStringList &attribs)
{
    //lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);	// recover the reference on the stack lua
	Reference<luaTrajectory>::getReference(luaL);
    ObserverDatagramPkg::SubjectAttribute trajSubj;
    return pop(luaL, attribs, &trajSubj, 0);
}

QByteArray luaTrajectory::getChanges(QDataStream& in , const QStringList &attribs)
{
    return getAll(in, attribs);
}

QByteArray luaTrajectory::pop(lua_State *luaL, const QStringList& attribs,
    ObserverDatagramPkg::SubjectAttribute *currSubj,
    ObserverDatagramPkg::SubjectAttribute *parentSubj)
{
    bool valueChanged = false;
    char result[20];
    double num = 0.0;

	const QStringList coordList = QStringList() << "x" << "y";

    // recover the reference on the stack lua
    //lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);
	Reference<luaTrajectory>::getReference(luaL);
    int position = lua_gettop(luaL);

    QByteArray key, valueTmp;
    ObserverDatagramPkg::RawAttribute *raw = 0;

    lua_pushnil(luaL);
    while(lua_next(luaL, position) != 0)
    {
        key = luaL_checkstring(luaL, -2);

        if ((attribs.contains(key)) || (key == "cells"))
        {
            switch(lua_type(luaL, -1))
            {
            case LUA_TBOOLEAN:
                valueTmp = QByteArray::number(lua_toboolean(luaL, -1));

                if (observedAttribs.value(key) != valueTmp)
                {
                    if ((parentSubj) && (!currSubj))
                        currSubj = parentSubj->add_internalsubject();

                    raw = currSubj->add_rawattributes();
                    raw->set_key(key);
                    raw->set_number(valueTmp.toDouble());

                    valueChanged = true;
                    observedAttribs.insert(key, valueTmp);
                }
                break;

            case LUA_TNUMBER:
                num = luaL_checknumber(luaL, -1);
                doubleToText(num, valueTmp, 20);

                if (observedAttribs.value(key) != valueTmp)
                {
                    if ((parentSubj) && (!currSubj))
                        currSubj = parentSubj->add_internalsubject();

                    raw = currSubj->add_rawattributes();
                    raw->set_key(key);
                    raw->set_number(num);

                    valueChanged = true;
                    observedAttribs.insert(key, valueTmp);
                }
                break;

            case LUA_TSTRING:
                valueTmp = luaL_checkstring(luaL, -1);

                if (observedAttribs.value(key) != valueTmp)
                {
                    if ((parentSubj) && (!currSubj))
                        currSubj = parentSubj->add_internalsubject();

                    raw = currSubj->add_rawattributes();
                    raw->set_key(key);
                    raw->set_text(valueTmp);

                    valueChanged = true;
                    observedAttribs.insert(key, valueTmp);
                }
                break;

            case LUA_TTABLE:
            {
                sprintf(result, "%p", lua_topointer(luaL, -1));
                valueTmp = result;

                if (observedAttribs.value(key) != valueTmp)
                {
                    if ((parentSubj) && (!currSubj))
                        currSubj = parentSubj->add_internalsubject();

                    raw = currSubj->add_rawattributes();
                    raw->set_key(key);
                    raw->set_text(LUA_ADDRESS_TABLE + static_cast<const char*>(result));

                    valueChanged = true;
                    observedAttribs.insert(key, valueTmp);
                }

                // Retrieves the cells table and picks up
                // the ID of each cell
                if (key == "cells")
                {
                    int top = lua_gettop(luaL);
                    int trajCount = 0;

                    lua_pushnil(luaL);
                    while(lua_next(luaL, top) != 0)
                    {
                        int cellTop = lua_gettop(luaL);
                        lua_pushstring(luaL, "cObj_");
                        lua_gettable(luaL, cellTop);

                        luaCell*  cell;
                        cell = (luaCell*)Luna<luaCell>::check(luaL, -1);
                        lua_pop(luaL, 1);

                        // luaCell->pop(...) requires a cell at the top of the stack

                        // // cellMsg = cell->pop(L, attribs);
                        // int internalCount = currSubj->internalsubject_size();
                        // cell->pop(luaL, coordList, 0, currSubj);

                        // if (currSubj->internalsubject_size() > internalCount)
                        //    valueChanged = true;

                        ObserverDatagramPkg::SubjectAttribute *cellSubj =
                        		currSubj->add_internalsubject();

                        // // Coordinate of cell
                        // const CellIndex &idx = cell->getIndex();

                        //raw = cellSubj->add_rawattributes();
                        //raw->set_key("x");
                        //raw->set_number((double)idx.first); // coordinate x

                        //raw = cellSubj->add_rawattributes();
                        //raw->set_key("y");
                        //raw->set_number((double)idx.second); // coordinate y

                        raw = cellSubj->add_rawattributes();
                        raw->set_key("trajectory");
                        raw->set_number(trajCount);

                        // Counts the occurrence of cell into trajectory
                        trajCount++;

                        cellSubj->set_id(cell->getId());
                        cellSubj->set_type(ObserverDatagramPkg::TObsCell);
                        cellSubj->set_attribsnumber(cellSubj->rawattributes_size());
                        cellSubj->set_itemsnumber(cellSubj->internalsubject_size());
                        valueChanged = true;

                        lua_pop(luaL, 1);
                    }
                }
                break;
            }

            case LUA_TUSERDATA:
            {
                sprintf(result, "%p", lua_topointer(luaL, -1));
                valueTmp = result;

                if (observedAttribs.value(key) != valueTmp)
                {
                    if ((parentSubj) && (!currSubj))
                        currSubj = parentSubj->add_internalsubject();

                    raw = currSubj->add_rawattributes();
                    raw->set_key(key);
                    raw->set_text(LUA_ADDRESS_USER_DATA
                    		+ static_cast<const char*>(result));

                    valueChanged = true;
                    observedAttribs.insert(key, valueTmp);
                }
                break;
            }

            case LUA_TFUNCTION:
            {
                sprintf(result, "%p", lua_topointer(luaL, -1));
                valueTmp = result;

                if (observedAttribs.value(key) != valueTmp)
                {
                    if ((parentSubj) && (!currSubj))
                        currSubj = parentSubj->add_internalsubject();

                    raw = currSubj->add_rawattributes();
                    raw->set_key(key);
                    raw->set_text(LUA_ADDRESS_FUNCTION
                    		+ static_cast<const char*>(result));

                    valueChanged = true;
                    observedAttribs.insert(key, valueTmp);
                }
                break;
            }

            default:
            {
                sprintf(result, "%p", lua_topointer(luaL, -1));
                valueTmp = result;

                if (observedAttribs.value(key) != valueTmp)
                {
                    if ((parentSubj) && (!currSubj))
                        currSubj = parentSubj->add_internalsubject();

                    raw = currSubj->add_rawattributes();
                    raw->set_key(key);
                    raw->set_text(LUA_ADDRESS_OTHER + static_cast<const char*>(result));

                    valueChanged = true;
                    observedAttribs.insert(key, valueTmp);
                }
                break;
            }
            }
        }
        lua_pop(luaL, 1);
    }

    if (valueChanged)
    {
        if ((parentSubj) && (!currSubj))
            currSubj = parentSubj->add_internalsubject();

        // id
        currSubj->set_id(getId());

        // subjectType
        currSubj->set_type(ObserverDatagramPkg::TObsTrajectory);

        // #attrs
        currSubj->set_attribsnumber(currSubj->rawattributes_size());

        // #elements
        currSubj->set_itemsnumber(currSubj->internalsubject_size());

        if (!parentSubj)
        {
            QByteArray byteArray(currSubj->SerializeAsString().c_str(),
            		currSubj->ByteSize());
            return byteArray;
        }
    }

    return QByteArray();
}

#else // TME_PROTOCOL_BUFFERS

QByteArray luaTrajectory::getAll(QDataStream& /*in*/, int /*observerId*/ ,
		const QStringList &attribs)
{
    lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);	// recover the reference on the stack lua
    return pop(luaL, attribs);
}

QByteArray luaTrajectory::getChanges(QDataStream& in, int observerId ,
		const QStringList &attribs)
{
    return getAll(in, observerId, attribs);
}

QByteArray luaTrajectory::pop(lua_State *luaL, const QStringList& attribs)
{
    QByteArray msg;

	QStringList coordList = QStringList() << "x" << "y";

    // id
    msg.append(QString::number(getId()));
    msg.append(PROTOCOL_SEPARATOR);

    // subjectType
    msg.append("6"); // QByteArray::number(subjectType));
    msg.append(PROTOCOL_SEPARATOR);

    int pos = lua_gettop(luaL);

    //------------
    int attrCounter = 0;
    int elementCounter = 0;
    // bool contains = false;
    double num = 0;
    QByteArray text, key, attrs, elements;

    lua_pushnil(luaL);
    while(lua_next(luaL, pos) != 0)
    {
        if (lua_type(luaL, -2) == LUA_TSTRING)
        {
            key = luaL_checkstring(luaL, -2);
        }
        else
        {
            if (lua_type(luaL, -2) == LUA_TNUMBER)
            {
                char aux[100];
                double number = luaL_checknumber(luaL, -2);
                sprintf(aux, "%g", number);
                key = aux;
            }
        }

        if ((attribs.contains(key)) || (key == "cells"))
        {
            attrCounter++;
            attrs.append(key);
            attrs.append(PROTOCOL_SEPARATOR);

            switch(lua_type(luaL, -1))
            {
            case LUA_TBOOLEAN:
                attrs.append(QByteArray::number(TObsBool));
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append(QByteArray::number(lua_toboolean(luaL, -1)));
                attrs.append(PROTOCOL_SEPARATOR);
                break;

            case LUA_TNUMBER:
                num = luaL_checknumber(luaL, -1);
                doubleToText(num, text, 20);
                attrs.append(QByteArray::number(TObsNumber));
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append(text);
                attrs.append(PROTOCOL_SEPARATOR);
                break;

            case LUA_TSTRING:
                text = QString(luaL_checkstring(luaL, -1));
                attrs.append(QByteArray::number(TObsText));
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append((text.isEmpty()
                		|| text.isNull() ? VALUE_NOT_INFORMED : text));
                attrs.append(PROTOCOL_SEPARATOR);
                break;

            case LUA_TTABLE:
                {
                    char result[100];
                    sprintf(result, "%p", lua_topointer(luaL, -1));
                    attrs.append(QByteArray::number(TObsText));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append("Lua-Address(TB): " + QByteArray(result));
                    attrs.append(PROTOCOL_SEPARATOR);

                    // Retrieves agents tables and delegates to
                    // each agent its serialization
                    // if (key == "cells")
                    {
                        int top = lua_gettop(luaL);

                        lua_pushnil(luaL);
                        while(lua_next(luaL, top) != 0)
                        {
                            int cellTop = lua_gettop(luaL);

                            lua_pushstring(luaL, "cObj_");
                            lua_gettable(luaL, cellTop);

                            luaCell*  cell;
                            cell = (luaCell*)Luna<luaCell>::check(L, -1);
                            lua_pop(luaL, 1);

                            // luaCell->popCell(...) requires a cell at the top of the stack
#ifdef TME_PROTOCOL_BUFFERS
                            QByteArray cellMsg = cell->pop(luaL, coordList, 0, 0);
#else
                            QByteArray cellMsg = cell->pop(luaL, coordList);
#endif
                            elements.append(cellMsg);
                            elementCounter++;

                            lua_pop(luaL, 1);
                        }
                    }
                    break;
                }

            case LUA_TUSERDATA	:
                {
                    char result[100];
                    sprintf(result, "%p", lua_topointer(luaL, -1));
                    attrs.append(QByteArray::number(TObsText));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append("Lua-Address(UD): " + QByteArray(result));
                    attrs.append(PROTOCOL_SEPARATOR);
                    break;
                }

            case LUA_TFUNCTION:
                {
                    char result[100];
                    sprintf(result, "%p", lua_topointer(luaL, -1));
                    attrs.append(QByteArray::number(TObsText));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append("Lua-Address(FT): " + QByteArray(result));
                    attrs.append(PROTOCOL_SEPARATOR);
                    break;
                }

            default:
                {
                    char result[100];
                    sprintf(result, "%p", lua_topointer(luaL, -1));
                    attrs.append(QByteArray::number(TObsText));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append("Lua-Address(O): " + QByteArray(result));
                    attrs.append(PROTOCOL_SEPARATOR);
                    break;
                }
            }
        }
        lua_pop(luaL, 1);
    }

    // #attrs
    msg.append(QByteArray::number(attrCounter));
    msg.append(PROTOCOL_SEPARATOR);

    // #elements
    msg.append(QByteArray::number(elementCounter));
    msg.append(PROTOCOL_SEPARATOR);
    msg.append(attrs);

    msg.append(PROTOCOL_SEPARATOR);
    msg.append(elements);
    msg.append(PROTOCOL_SEPARATOR);

    return msg;
}

#endif // ifdef TME_PROTOCOL_BUFFERS

int luaTrajectory::kill(lua_State *luaL)
{
    int id = luaL_checknumber(luaL, 1);
    bool result = false;

    result = TrajectorySubjectInterf::kill(id);

    if (!result)
    {
        if (cellSpace)
        {
            Observer *obs = cellSpace->getObserverById(id);

            if (obs)
            {
                if (obs->getType() == TObsMap)
                    result = ((AgentObserverMap *)obs)->unregistry(this);
                else
                    result = ((AgentObserverImage *)obs)->unregistry(this);
            }
        }
    }
    lua_pushboolean(luaL, result);
    return 1;
}

//#include <QFile>
//#include <QTextStream>
//void luaTrajectory::save(const QString &msg)
//{
//    QFile file("trajectoryPop.txt");
//    if (!file.open(QIODevice::WriteOnly | QIODevice::Append))
//        return;
//
//    QStringList list = msg.split(PROTOCOL_SEPARATOR, QString::SkipEmptyParts);
//    QTextStream out(&file);
//
//    foreach(QString s, list)
//        out << s << " ";
//    out << "\n";
//}
