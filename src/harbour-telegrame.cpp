
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlEngine>
#include <QUrl>
#include <QSortFilterProxyModel>

#include <qqml.h>
#include <sailfishapp.h>
#include <nemonotifications-qt5/notification.h>

#include "QtQmlTricks.h"

#include "QtTdLibEnums.h"
#include "QtTdLibJsonWrapper.h"
#include "QtTdLibConnection.h"
#include "QtTdLibAuth.h"
#include "QtTdLibGlobal.h"
#include "QtTdLibUser.h"
#include "QtTdLibContent.h"
#include "QtTdLibMessage.h"
#include "QtTdLibFile.h"
#include "QtTdLibChat.h"
#include "TextFormatter.h"

int main (int argc, char * argv []) {
    QtQmlTricks::registerComponents ();
    qmlRegisterType<TextFormatter>                                ("harbour.Telegrame", 1, 0, "TextFormatter");
    qmlRegisterType<QSortFilterProxyModel>                        ("harbour.Telegrame", 1, 0, "SortFilterProxyModel");
    qmlRegisterType<QtTdLibMessageRefWatcher>                     ("harbour.Telegrame", 1, 0, "TD_MessageRefWatcher");
    qmlRegisterType<QtTdLibAbstractObject>                        ("harbour.Telegrame", 1, 0, "TD_AbstractObject");
    qmlRegisterType<QtTdLibAnimation>                             ("harbour.Telegrame", 1, 0, "TD_Animation");
    qmlRegisterType<QtTdLibAudio>                                 ("harbour.Telegrame", 1, 0, "TD_Audio");
    qmlRegisterType<QtTdLibAuthenticationCodeInfo>                ("harbour.Telegrame", 1, 0, "TD_AuthenticationCodeInfo");
    qmlRegisterType<QtTdLibAuthenticationCodeType>                ("harbour.Telegrame", 1, 0, "TD_AuthenticationCodeType");
    qmlRegisterType<QtTdLibAuthenticationCodeTypeCall>            ("harbour.Telegrame", 1, 0, "TD_AuthenticationCodeTypeCall");
    qmlRegisterType<QtTdLibAuthenticationCodeTypeFlashCall>       ("harbour.Telegrame", 1, 0, "TD_AuthenticationCodeTypeFlashCall");
    qmlRegisterType<QtTdLibAuthenticationCodeTypeSms>             ("harbour.Telegrame", 1, 0, "TD_AuthenticationCodeTypeSms");
    qmlRegisterType<QtTdLibAuthenticationCodeTypeTelegramMessage> ("harbour.Telegrame", 1, 0, "TD_AuthenticationCodeTypeTelegramMessage");
    qmlRegisterType<QtTdLibAuthorizationState>                    ("harbour.Telegrame", 1, 0, "TD_AuthorizationState");
    qmlRegisterType<QtTdLibAuthorizationStateClosed>              ("harbour.Telegrame", 1, 0, "TD_AuthorizationStateClosed");
    qmlRegisterType<QtTdLibAuthorizationStateClosing>             ("harbour.Telegrame", 1, 0, "TD_AuthorizationStateClosing");
    qmlRegisterType<QtTdLibAuthorizationStateLoggingOut>          ("harbour.Telegrame", 1, 0, "TD_AuthorizationStateLoggingOut");
    qmlRegisterType<QtTdLibAuthorizationStateReady>               ("harbour.Telegrame", 1, 0, "TD_AuthorizationStateReady");
    qmlRegisterType<QtTdLibAuthorizationStateWaitCode>            ("harbour.Telegrame", 1, 0, "TD_AuthorizationStateWaitCode");
    qmlRegisterType<QtTdLibAuthorizationStateWaitEncryptionKey>   ("harbour.Telegrame", 1, 0, "TD_AuthorizationStateWaitEncryptionKey");
    qmlRegisterType<QtTdLibAuthorizationStateWaitPassword>        ("harbour.Telegrame", 1, 0, "TD_AuthorizationStateWaitPassword");
    qmlRegisterType<QtTdLibAuthorizationStateWaitPhoneNumber>     ("harbour.Telegrame", 1, 0, "TD_AuthorizationStateWaitPhoneNumber");
    qmlRegisterType<QtTdLibAuthorizationStateWaitTdlibParameters> ("harbour.Telegrame", 1, 0, "TD_AuthorizationStateWaitParameters");
    qmlRegisterType<QtTdLibBasicGroup>                            ("harbour.Telegrame", 1, 0, "TD_BasicGroup");
    qmlRegisterType<QtTdLibCallDiscardReason>                     ("harbour.Telegrame", 1, 0, "TD_CallDiscardReason");
    qmlRegisterType<QtTdLibCallDiscardReasonDeclined>             ("harbour.Telegrame", 1, 0, "TD_CallDiscardReasonDeclined");
    qmlRegisterType<QtTdLibCallDiscardReasonDisconnected>         ("harbour.Telegrame", 1, 0, "TD_CallDiscardReasonDisconnected");
    qmlRegisterType<QtTdLibCallDiscardReasonEmpty>                ("harbour.Telegrame", 1, 0, "TD_CallDiscardReasonEmpty");
    qmlRegisterType<QtTdLibCallDiscardReasonHungUp>               ("harbour.Telegrame", 1, 0, "TD_CallDiscardReasonHungUp");
    qmlRegisterType<QtTdLibCallDiscardReasonMissed>               ("harbour.Telegrame", 1, 0, "TD_CallDiscardReasonMissed");
    qmlRegisterType<QtTdLibChat>                                  ("harbour.Telegrame", 1, 0, "TD_Chat");
    qmlRegisterType<QtTdLibChatNotificationSettings>              ("harbour.Telegrame", 1, 0, "TD_ChatNotificationSettings");
    qmlRegisterType<QtTdLibChatPhoto>                             ("harbour.Telegrame", 1, 0, "TD_ChatPhoto");
    qmlRegisterType<QtTdLibChatType>                              ("harbour.Telegrame", 1, 0, "TD_ChatType");
    qmlRegisterType<QtTdLibChatTypeBasicGroup>                    ("harbour.Telegrame", 1, 0, "TD_ChatTypeBasicGroup");
    qmlRegisterType<QtTdLibChatTypePrivate>                       ("harbour.Telegrame", 1, 0, "TD_ChatTypePrivate");
    qmlRegisterType<QtTdLibChatTypeSecret>                        ("harbour.Telegrame", 1, 0, "TD_ChatTypeSecret");
    qmlRegisterType<QtTdLibChatTypeSupergroup>                    ("harbour.Telegrame", 1, 0, "TD_ChatTypeSupergroup");
    qmlRegisterType<QtTdLibChatMember>                            ("harbour.Telegrame", 1, 0, "TD_ChatMember");
    qmlRegisterType<QtTdLibChatMemberStatus>                      ("harbour.Telegrame", 1, 0, "TD_ChatMemberStatus");
    qmlRegisterType<QtTdLibChatMemberStatusAdministrator>         ("harbour.Telegrame", 1, 0, "TD_ChatMemberStatusAdministrator");
    qmlRegisterType<QtTdLibChatMemberStatusBanned>                ("harbour.Telegrame", 1, 0, "TD_ChatMemberStatusBanned");
    qmlRegisterType<QtTdLibChatMemberStatusCreator>               ("harbour.Telegrame", 1, 0, "TD_ChatMemberStatusCreator");
    qmlRegisterType<QtTdLibChatMemberStatusLeft>                  ("harbour.Telegrame", 1, 0, "TD_ChatMemberStatusLeft");
    qmlRegisterType<QtTdLibChatMemberStatusMember>                ("harbour.Telegrame", 1, 0, "TD_ChatMemberStatusMember");
    qmlRegisterType<QtTdLibChatMemberStatusRestricted>            ("harbour.Telegrame", 1, 0, "TD_ChatMemberStatusRestricted");
    qmlRegisterType<QtTdLibConnectionState>                       ("harbour.Telegrame", 1, 0, "TD_ConnectionState");
    qmlRegisterType<QtTdLibConnectionStateConnecting>             ("harbour.Telegrame", 1, 0, "TD_ConnectionStateConnecting");
    qmlRegisterType<QtTdLibConnectionStateConnectingToProxy>      ("harbour.Telegrame", 1, 0, "TD_ConnectionStateConnectingToProxy");
    qmlRegisterType<QtTdLibConnectionStateReady>                  ("harbour.Telegrame", 1, 0, "TD_ConnectionStateReady");
    qmlRegisterType<QtTdLibConnectionStateUpdating>               ("harbour.Telegrame", 1, 0, "TD_ConnectionStateUpdating");
    qmlRegisterType<QtTdLibConnectionStateWaitingForNetwork>      ("harbour.Telegrame", 1, 0, "TD_ConnectionStateWaitingForNetwork");
    qmlRegisterType<QtTdLibDocument>                              ("harbour.Telegrame", 1, 0, "TD_Document");
    qmlRegisterType<QtTdLibFile>                                  ("harbour.Telegrame", 1, 0, "TD_File");
    qmlRegisterType<QtTdLibFormattedText>                         ("harbour.Telegrame", 1, 0, "TD_FormattedText");
    qmlRegisterType<QtTdLibLinkState>                             ("harbour.Telegrame", 1, 0, "TD_LinkState");
    qmlRegisterType<QtTdLibLocalFile>                             ("harbour.Telegrame", 1, 0, "TD_LocalFile");
    qmlRegisterType<QtTdLibMessage>                               ("harbour.Telegrame", 1, 0, "TD_Message");
    qmlRegisterType<QtTdLibMessageAnimation>                      ("harbour.Telegrame", 1, 0, "TD_MessageAnimation");
    qmlRegisterType<QtTdLibMessageAudio>                          ("harbour.Telegrame", 1, 0, "TD_MessageAudio");
    qmlRegisterType<QtTdLibMessageBasicGroupChatCreate>           ("harbour.Telegrame", 1, 0, "TD_MessageBasicGroupChatCreate");
    qmlRegisterType<QtTdLibMessageCall>                           ("harbour.Telegrame", 1, 0, "TD_MessageCall");
    qmlRegisterType<QtTdLibMessageChatAddMembers>                 ("harbour.Telegrame", 1, 0, "TD_MessageChatAddMembers");
    qmlRegisterType<QtTdLibMessageChatChangePhoto>                ("harbour.Telegrame", 1, 0, "TD_MessageChatChangePhoto");
    qmlRegisterType<QtTdLibMessageChatChangeTitle>                ("harbour.Telegrame", 1, 0, "TD_MessageChatChangeTitle");
    qmlRegisterType<QtTdLibMessageChatDeleteMember>               ("harbour.Telegrame", 1, 0, "TD_MessageChatDeleteMember");
    qmlRegisterType<QtTdLibMessageChatDeletePhoto>                ("harbour.Telegrame", 1, 0, "TD_MessageChatDeletePhoto");
    qmlRegisterType<QtTdLibMessageChatJoinByLink>                 ("harbour.Telegrame", 1, 0, "TD_MessageChatJoinByLink");
    qmlRegisterType<QtTdLibMessageChatUpgradeFrom>                ("harbour.Telegrame", 1, 0, "TD_MessageChatUpgradeFrom");
    qmlRegisterType<QtTdLibMessageChatUpgradeTo>                  ("harbour.Telegrame", 1, 0, "TD_MessageChatUpgradeTo");
    qmlRegisterType<QtTdLibMessageContactRegistered>              ("harbour.Telegrame", 1, 0, "TD_MessageContactRegistered");
    qmlRegisterType<QtTdLibMessagePinMessage>                     ("harbour.Telegrame", 1, 0, "TD_MessagePinMessage");
    qmlRegisterType<QtTdLibMessageContent>                        ("harbour.Telegrame", 1, 0, "TD_MessageContent");
    qmlRegisterType<QtTdLibMessageDocument>                       ("harbour.Telegrame", 1, 0, "TD_MessageDocument");
    qmlRegisterType<QtTdLibMessagePhoto>                          ("harbour.Telegrame", 1, 0, "TD_MessagePhoto");
    qmlRegisterType<QtTdLibMessageSticker>                        ("harbour.Telegrame", 1, 0, "TD_MessageSticker");
    qmlRegisterType<QtTdLibMessageSupergroupChatCreate>           ("harbour.Telegrame", 1, 0, "TD_MessageSupergroupChatCreate");
    qmlRegisterType<QtTdLibMessageText>                           ("harbour.Telegrame", 1, 0, "TD_MessageText");
    qmlRegisterType<QtTdLibMessageVideo>                          ("harbour.Telegrame", 1, 0, "TD_MessageVideo");
    qmlRegisterType<QtTdLibMessageVideoNote>                      ("harbour.Telegrame", 1, 0, "TD_MessageVideoNote");
    qmlRegisterType<QtTdLibMessageVoiceNote>                      ("harbour.Telegrame", 1, 0, "TD_MessageVoiceNote");
    qmlRegisterType<QtTdLibPhoto>                                 ("harbour.Telegrame", 1, 0, "TD_Photo");
    qmlRegisterType<QtTdLibPhotoSize>                             ("harbour.Telegrame", 1, 0, "TD_PhotoSize");
    qmlRegisterType<QtTdLibProfilePhoto>                          ("harbour.Telegrame", 1, 0, "TD_ProfilePhoto");
    qmlRegisterType<QtTdLibRemoteFile>                            ("harbour.Telegrame", 1, 0, "TD_RemoteFile");
    qmlRegisterType<QtTdLibSticker>                               ("harbour.Telegrame", 1, 0, "TD_Sticker");
    qmlRegisterType<QtTdLibStickerSetInfo>                        ("harbour.Telegrame", 1, 0, "TD_StickerSet");
    qmlRegisterType<QtTdLibSupergroup>                            ("harbour.Telegrame", 1, 0, "TD_Supergroup");
    qmlRegisterType<QtTdLibTextEntity>                            ("harbour.Telegrame", 1, 0, "TD_TextEntity");
    qmlRegisterType<QtTdLibTextEntityType>                        ("harbour.Telegrame", 1, 0, "TD_TextEntityType");
    qmlRegisterType<QtTdLibTextEntityTypeBold>                    ("harbour.Telegrame", 1, 0, "TD_TextEntityTypeBold");
    qmlRegisterType<QtTdLibTextEntityTypeBotCommand>              ("harbour.Telegrame", 1, 0, "TD_TextEntityTypeBotCommand");
    qmlRegisterType<QtTdLibTextEntityTypeCode>                    ("harbour.Telegrame", 1, 0, "TD_TextEntityTypeCode");
    qmlRegisterType<QtTdLibTextEntityTypeEmailAddress>            ("harbour.Telegrame", 1, 0, "TD_TextEntityTypeEmailAddress");
    qmlRegisterType<QtTdLibTextEntityTypeHashtag>                 ("harbour.Telegrame", 1, 0, "TD_TextEntityTypeHashtag");
    qmlRegisterType<QtTdLibTextEntityTypeItalic>                  ("harbour.Telegrame", 1, 0, "TD_TextEntityTypeItalic");
    qmlRegisterType<QtTdLibTextEntityTypeMention>                 ("harbour.Telegrame", 1, 0, "TD_TextEntityTypeMention");
    qmlRegisterType<QtTdLibTextEntityTypeMentionName>             ("harbour.Telegrame", 1, 0, "TD_TextEntityTypeMentionName");
    qmlRegisterType<QtTdLibTextEntityTypePre>                     ("harbour.Telegrame", 1, 0, "TD_TextEntityTypePre");
    qmlRegisterType<QtTdLibTextEntityTypePreCode>                 ("harbour.Telegrame", 1, 0, "TD_TextEntityTypePreCode");
    qmlRegisterType<QtTdLibTextEntityTypeTextUrl>                 ("harbour.Telegrame", 1, 0, "TD_TextEntityTypeTextUrl");
    qmlRegisterType<QtTdLibTextEntityTypeUrl>                     ("harbour.Telegrame", 1, 0, "TD_TextEntityTypeUrl");
    qmlRegisterType<QtTdLibUser>                                  ("harbour.Telegrame", 1, 0, "TD_User");
    qmlRegisterType<QtTdLibUserStatus>                            ("harbour.Telegrame", 1, 0, "TD_UserStatus");
    qmlRegisterType<QtTdLibUserType>                              ("harbour.Telegrame", 1, 0, "TD_UserType");
    qmlRegisterType<QtTdLibVideo>                                 ("harbour.Telegrame", 1, 0, "TD_Video");
    qmlRegisterType<QtTdLibVideoNote>                             ("harbour.Telegrame", 1, 0, "TD_VideoNote");
    qmlRegisterType<QtTdLibVoiceNote>                             ("harbour.Telegrame", 1, 0, "TD_VoiceNote");
    qmlRegisterType<QtTdLibWebPage>                               ("harbour.Telegrame", 1, 0, "TD_WebPage");
    qmlRegisterSingletonType<QtTdLibGlobal>                       ("harbour.Telegrame", 1, 0, "TD_Global", &QtTdLibGlobal::qmlSingletonFactory);
    qmlRegisterUncreatableType<QtTdLibObjectType>                 ("harbour.Telegrame", 1, 0, "TD_ObjectType", "Enum class !");
    QGuiApplication * app { SailfishApp::application (argc, argv) };
    app->setApplicationName ("harbour-telegrame");
    const QList<QObject *> oldNoticationsList { Notification::notifications () };
    for (QObject * tmp : oldNoticationsList) {
        if (Notification * notification = { qobject_cast<Notification *> (tmp) }) {
            notification->close ();
            notification->deleteLater ();
        }
    }
    QQuickView * view { SailfishApp::createView () };
    view->setSource (QUrl { "qrc:///qml/harbour-telegrame.qml" });
    view->show ();
    return app->exec ();
}
