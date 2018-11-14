import QtQuick 2.6;
import QtMultimedia 5.6;

Loader {
    id: wrapper;
    active: false;
    sourceComponent: VideoOutput {
        smooth: true;
        fillMode: VideoOutput.PreserveAspectFit;
        antialiasing: true;
        source: MediaPlayer {
            Binding on loops    { value: (wrapper.loop ? MediaPlayer.Infinite : 1); }
            Binding on muted    { value: wrapper.muted; }
            Binding on source   { value: wrapper.source; }
            Binding on autoPlay { value: wrapper.autoPlay; }
            Binding on autoLoad { value: wrapper.autoLoad; }
        }
    }

    property bool loop     : false;
    property bool muted    : false;
    property bool autoLoad : false;
    property bool autoPlay : false;

    property string source : "";

    readonly property VideoOutput video : item;
    readonly property MediaPlayer media : (video ? video.source : null);

    readonly property int duration  : (media ? media.duration : 0);
    readonly property int position  : (media ? media.position : 0);
    readonly property int remaining : (duration - position);

    readonly property bool playing : (media && media.playbackState === MediaPlayer.PlayingState);

    readonly property real progress : (duration > 0 ? position / duration : 0.0);

    function play () {
        if (media) {
            media.play ();
        }
    }

    function pause () {
        if (media) {
            media.pause ();
        }
    }

    function stop () {
        if (media) {
            media.stop ();
        }
    }

    function seek (position) {
        if (media) {
            media.seek (position);
        }
    }
}
