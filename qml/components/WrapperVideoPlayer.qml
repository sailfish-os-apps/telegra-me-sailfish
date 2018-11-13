import QtQuick 2.6;
import QtMultimedia 5.6;

Loader {
    id: wrapper;
    active: false;
    sourceComponent: Video {
        smooth: true;
        fillMode: VideoOutput.PreserveAspectFit;
        antialiasing: true;

        Binding on source   { value: wrapper.source; }
        Binding on autoPlay { value: wrapper.autoPlay; }
        Binding on autoLoad { value: wrapper.autoLoad; }
    }

    property bool autoLoad : false;
    property bool autoPlay : false;

    property string source : "";

    readonly property Video video : item;

    readonly property int duration : (video ? video.duration : 0);
    readonly property int position : (video ? video.position : 0);

    readonly property bool playing : (video && video.playbackState === MediaPlayer.PlayingState);

    readonly property real progress : (duration > 0 ? position / duration : 0.0);

    function play () {
        if (video) {
            video.play ();
        }
    }

    function pause () {
        if (video) {
            video.pause ();
        }
    }

    function stop () {
        if (video) {
            video.stop ();
        }
    }
}
