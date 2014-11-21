/*************************************************************************
 * Copyright (C) 2014 by Hugo Pereira Da Costa <hugo.pereira@free.fr>    *
 *                                                                       *
 * This program is free software; you can redistribute it and/or modify  *
 * it under the terms of the GNU General Public License as published by  *
 * the Free Software Foundation; either version 2 of the License, or     *
 * (at your option) any later version.                                   *
 *                                                                       *
 * This program is distributed in the hope that it will be useful,       *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 * GNU General Public License for more details.                          *
 *                                                                       *
 * You should have received a copy of the GNU General Public License     *
 * along with this program; if not, write to the                         *
 * Free Software Foundation, Inc.,                                       *
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 *************************************************************************/

#include "mendabusyindicatorengine.h"
#include "mendabusyindicatorengine.moc"

#include "menda.h"

#include <QVariant>

namespace Menda
{

    //_______________________________________________
    BusyIndicatorEngine::BusyIndicatorEngine( QObject* object ):
        BaseEngine( object ),
        _animation( new Animation( duration(), this ) )
    {

        // setup animation
        _animation.data()->setStartValue( 0 );
        _animation.data()->setEndValue( 2*Metrics::ProgressBar_BusyIndicatorSize );
        _animation.data()->setTargetObject( this );
        _animation.data()->setPropertyName( "value" );
        _animation.data()->setLoopCount( -1 );

    }

    //_______________________________________________
    bool BusyIndicatorEngine::registerWidget( QObject* object )
    {

        // check widget validity
        if( !object ) return false;

         // create new data class
        if( !_data.contains( object ) )
        {
            _data.insert( object, new BusyIndicatorData( this ) );

            // connect destruction signal
            connect( object, SIGNAL(destroyed(QObject*)), this, SLOT(unregisterWidget(QObject*)), Qt::UniqueConnection );
        }

        return true;

    }

    //____________________________________________________________
    bool BusyIndicatorEngine::isAnimated( const QObject* object )
    {

        DataMap<BusyIndicatorData>::Value data( BusyIndicatorEngine::data( object ) );
        return data && data.data()->isAnimated();

    }

    //____________________________________________________________
    void BusyIndicatorEngine::setDuration( int value )
    {

        if( duration() == value ) return;
        BaseEngine::setDuration( value );

        // restart timer with specified time
        _animation.data()->setDuration( value );

    }

    //____________________________________________________________
    void BusyIndicatorEngine::setAnimated( const QObject* object, bool value )
    {

        DataMap<BusyIndicatorData>::Value data( BusyIndicatorEngine::data( object ) );
        if( data )
        {
            // update data
            data.data()->setAnimated( value );

            // start timer if needed
            if( value && !_animation.data()->isRunning() )
            { _animation.data()->start(); }

        }

        return;

    }


    //____________________________________________________________
    DataMap<BusyIndicatorData>::Value BusyIndicatorEngine::data( const QObject* object )
    { return _data.find( object ).data(); }

    //_______________________________________________
    void BusyIndicatorEngine::setValue( int value )
    {

        // update
        _value = value;

        bool animated( false );

        // loop over objects in map
        for( DataMap<BusyIndicatorData>::iterator iter = _data.begin(); iter != _data.end(); ++iter )
        {

            if( iter.value().data()->isAnimated() )
            {

                // update animation flag
                animated = true;

                // emit update signal on object
                if( const_cast<QObject*>( iter.key() )->inherits( "QQuickStyleItem" ))
                {

                    //QtQuickControls "rerender" method is updateItem
                    QMetaObject::invokeMethod( const_cast<QObject*>( iter.key() ), "updateItem", Qt::QueuedConnection);

                } else {

                    QMetaObject::invokeMethod( const_cast<QObject*>( iter.key() ), "update", Qt::QueuedConnection);

                }

            }

        }

        if( !animated ) _animation.data()->stop();

    }

}
