declare namespace osm="urn:com:metasolv:oms:xmlapi:1";
declare namespace context = "java:com.mslv.oms.automation.OrderDataChangeNotificationContext";
declare namespace log = "java:org.apache.commons.logging.Log";
declare namespace saxon="http://saxon.sf.net/";
declare namespace xsl="http://www.w3.org/1999/XSL/Transform";

declare variable $context external;
declare variable $log external;


declare function local:getServiceType(
    $serviceType as xs:string,
    ) as xs:string {
    
        let $type := if (exists($serviceType)) then 
        (
            if ($serviceType = 'SISMovel')
                then 'Mobile'
                else(
                
                  if ($serviceType = 'OSM')
                then 'ADSL'
                else(
                
                 if ($serviceType = 'STC')
                then 'Fixed'
                else(
                
                  if ($serviceType = 'Expediter')
                then 'ADSL'
                else(
                )
                )
                )

                )
        ) 
        else ()
        return
	$type
};

declare function local:getProvisioningFunction($order as element(), $change as element()*) as element()* {

          
let $isUpdate := fn:local-name($change[1]) = 'Update'
let $changedElemId := fn:substring-after($change[1]/@path, "'")
let $changedElemId := fn:substring-before($changedElemId,"'")
let $provisioningFunction := if ($isUpdate) 
                    then $order/osm:_root/osm:ControlData/osm:Functions/osm:ProvisioningFunction[osm:Status/osm:ErrorCode[@index=$changedElemId]]
                    else $order/osm:_root/osm:ControlData/osm:Functions/osm:ProvisioningFunction[osm:Status[@index=$changedElemId]]
        return 
               $provisioningFunction
            
};
let $order := ..//osm:GetOrder.Response
let $dataChangeNotification := if (exists(fn:root(.)//DataChangeNotification)) 
                               then fn:root(.)//DataChangeNotification 
                               else ()
let $updates := if (exists($dataChangeNotification/Changes/Update[fn:starts-with(@path, '/ControlData/Functions/ProvisioningFunction/Status')])) 
                         then $dataChangeNotification/Changes/Update[fn:starts-with(@path, '/ControlData/Functions/ProvisioningFunction/Status')]
                         else (
                         
                         if (exists($dataChangeNotification/Changes/Add[fn:starts-with(@path, '/ControlData/Functions/ProvisioningFunction/Status')])) 
                         then $dataChangeNotification/Changes/Add[fn:starts-with(@path, '/ControlData/Functions/ProvisioningFunction/Status')]
                         else ()
                         
                         )
                         
let $changedElemId := fn:substring-after($updates[1]/@path, "'")
let $changedElemId := fn:substring-before($changedElemId,"'")
let $function := local:getProvisioningFunction($order, $updates)
let $componentKey := $function/osm:componentKey/text()
let $serviceType := if (exists($componentKey))
    then fn:tokenize($componentKey, '\.')[2]
    else ()
 let $type := if (exists($serviceType)) then 
        (
           local:getServiceType($serviceType)
        ) 
        else ()
let $requestStr := saxon:serialize(fn:root(), <xsl:output method='xml' omit-xml-declaration='yes' indent='yes' saxon:indent-spaces='4'/>)
let $functions := saxon:serialize($function, <xsl:output method='xml' omit-xml-declaration='yes' indent='yes' saxon:indent-spaces='4'/>)
return
(
log:info($log,'update provisioning status'),
log:info($log,fn:concat('componentKey:', $componentKey)),
log:info($log,fn:concat('changeId:', $changedElemId)),
(:log:info($log,fn:concat('inputXML:', $requestStr)),
log:info($log,fn:concat('functions:', $functions)),:)
<requestResponse>
	<numSalesOrder>{$order/osm:Reference/text()}</numSalesOrder>
	<numOrder>{$order/osm:OrderID/text()}</numOrder>
	<serviceType>{$type}</serviceType>
	<typeOrder>{$order//osm:OrderHeader/osm:typeOrder/text()}</typeOrder>
	<errorCode>{$function/osm:Status/osm:ErrorCode/text()}</errorCode>
	<status>{$function/osm:Status/osm:ErrorStatus/text()}</status>
	<message>{$function/osm:Status/osm:ErrorMessage/text()}</message>
</requestResponse>

)