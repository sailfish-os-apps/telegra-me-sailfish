import QtQuick 2.6;
import QtMultimedia 5.6;

Loader {
    id: wrapper;
    active: false;
    visible: false; // NOTE : normal
    sourceComponent: MediaPlayer {

        Binding on source   { value: wrapper.source; }
        Binding on autoPlay { value: wrapper.autoPlay; }
        Binding on autoLoad { value: wrapper.autoLoad; }
    }

    property bool autoLoad : false;
    property bool autoPlay : false;

    property string source : "";

    readonly property MediaPlayer audio : item;

    readonly property int duration  : (audio ? audio.duration : 0);
    readonly property int position  : (audio ? audio.position : 0);
    readonly property int remaining : (duration - position);

    readonly property bool playing : (audio && audio.playbackState === MediaPlayer.PlayingState);

    readonly property real progress : (duration > 0 ? position / duration : 0.0);

    function play () {
        if (audio) {
            audio.play ();
        }
    }

    function pause () {
        if (audio) {
            audio.pause ();
        }
    }

    function stop () {
        if (audio) {
            audio.stop ();
        }
    }

    function seek (position) {
        if (audio) {
            audio.seek (position);
        }
    }
}
