declare namespace oms="urn:com:metasolv:oms:xmlapi:1";
(: JAVA APIs namespaces :)
declare namespace UUID = "java:java.util.UUID";
(: only require to be declared when editing with Oxygen :)
declare namespace automator = "java:oracle.communications.ordermanagement.automation.plugin.ScriptReceiverContextInvocation";
(: only require to be declared when editing with Oxygen :)
declare namespace context = "java:com.mslv.oms.automation.TaskContext";
declare namespace log = "java:org.apache.commons.logging.Log";

declare namespace res = "http://xmlns.oracle.com/communications/sce/dictionary/OsmCentralOMExample/interactionResponse";
declare option saxon:output "method=xml";
declare option saxon:output "saxon:indent-spaces=4";

declare variable $automator external;
declare variable $context external;
declare variable $log external;

let $response := fn:root()

return (
    log:info($log,'received collections response'),
    automator:setUpdateOrder($automator,"true"),
    context:completeTaskOnExit($context,"success"),
    (
        <OrderDataUpdate xmlns="http://www.metasolv.com/OMS/OrderDataUpdate/2002/10/25">
            <UpdatedNodes>
                <_root>
                     <Status>
                            <CollectionsStatus>
                                <Status>
                                    <ErrorCode>{fn:root()/res:orderResponse/res:errorCode/text()}</ErrorCode>
                                    <ErrorStatus>{fn:root()/res:orderResponse/res:status/text()}</ErrorStatus>
                                    <ErrorMessage>{fn:root()/res:orderResponse/res:message/text()}</ErrorMessage>
                                </Status>
                            </CollectionsStatus>
                        </Status>
                </_root>
            </UpdatedNodes>
        </OrderDataUpdate>
    )
)
