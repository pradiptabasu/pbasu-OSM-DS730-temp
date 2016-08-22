declare namespace oms="urn:com:metasolv:oms:xmlapi:1";
declare namespace saxon="http://saxon.sf.net/";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";
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

let $response := fn:root()/res:orderResponse

let $cancel := fn:root()/res:cancelResponse
let $responseRoot := if (exists($response)) then ($response) else ($cancel)
let $update := <UpdateOrder.Request xmlns="urn:com:metasolv:oms:xmlapi:1">
                <OrderID>{ context:getOrderId($context) }</OrderID>
                <View>OsmCentralOMExampleCreationTask</View>
               <UpdatedNodes>
                <_root>
                                     <Status>
                            <BillingStatus>
                                <Status>
                                    <ErrorCode>{$responseRoot/res:errorCode/text()}</ErrorCode>
                                    <ErrorStatus>{$responseRoot/res:status/text()}</ErrorStatus>
                                    <ErrorMessage>{$responseRoot/res:message/text()}</ErrorMessage>
                                </Status>
                            </BillingStatus>
                 </Status>
                </_root>
            </UpdatedNodes>
            </UpdateOrder.Request>
let $requestStr := saxon:serialize($update, <xsl:output method='xml' omit-xml-declaration='yes' indent='yes' saxon:indent-spaces='4'/>)
return (
    log:info($log,'received billing response'),
    automator:setUpdateOrder($automator,"true"),
    context:completeTaskOnExit($context,"success"),
    (
      if (exists($cancel)) then (
         automator:setUpdateOrder($automator,"false"),
         log:info($log, fn:concat('BILLING UPDATE ORDER: ' , $requestStr)),
        let $ret :=  context:processXMLRequest($context, $requestStr)
        return 
        log:info($log, fn:concat('BILLING UPDATE ORDER RESPONSE: ' , $ret))
         
              
        ) else (
        <OrderDataUpdate xmlns="http://www.metasolv.com/OMS/OrderDataUpdate/2002/10/25">
            <UpdatedNodes>
                <_root>
                 <Status>
                            <BillingStatus>
                                <Status>
                                    <ErrorCode>{$responseRoot/res:errorCode/text()}</ErrorCode>
                                    <ErrorStatus>{$responseRoot/res:status/text()}</ErrorStatus>
                                    <ErrorMessage>{$responseRoot/res:message/text()}</ErrorMessage>
                                </Status>
                            </BillingStatus>
                 </Status>
                </_root>
            </UpdatedNodes>
        </OrderDataUpdate>
    )
    )
)
