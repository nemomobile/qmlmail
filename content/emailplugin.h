/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef __emailplugin_h
#define __emailplugin_h

#include <QObject>

#include <feedplugin.h>

class McaServiceModel;
class McaFeedModel;
class EmailServiceModel;

class EmailPlugin: public QObject, public McaFeedPlugin
{
    Q_OBJECT
    Q_INTERFACES(McaFeedPlugin)

public:
    explicit EmailPlugin(QObject *parent = NULL);
    ~EmailPlugin();

    QAbstractItemModel *serviceModel();
    QAbstractItemModel *createFeedModel(const QString& service);
    McaSearchableFeed *createSearchModel(const QString& service,
                                         const QString& searchText);

private:
    EmailServiceModel *m_serviceModel;
};

#endif  // __emailplugin_h
