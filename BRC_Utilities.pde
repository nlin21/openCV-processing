import processing.net.*;

Server BRCServer;

int BRC_port = 10002;
int BRC_WebBodySize = 15532;

String[] BRC_ids = new String[] {"cameraOn","fileName","init","object","faceRecognition","brightness","adjustBrightness","contrast","adjustContrast","filter","thresholdValue","blurValue","adaptiveBlockSize","adaptiveConstant","imageFilter","findContours","contourThreshold","filterType","findEdges","findLines","findLinesThreshold","findLinesMinLength","findLinesMaxLineGap","backgroundSubtraction","colorChannels"};
String[] BRC_values = new String[] {"false","","0","face","0","50","0","0","0","t","80","50","51","50","0","0","80","canny","0","0","100","30","20","0","0"};

String[] BRC_Monitors = new String[] {};
String[] BRC_MonitorValues = new String[] {};


ArrayList BRC_changed = new ArrayList();
boolean BRC_ShowMessages = false;
boolean BRC_Initialized = false;

void brcInit() {
  BRCServer = new Server(this,BRC_port);
  println("BRCFactory version 1.01");
  println("0. Create a small browser window.");
  println("1. Go to the url:  127.0.0.1:10002");
}

void brc() {
  if (!BRC_Initialized) {
    brcInit();
    BRC_Initialized = true;
  }
  brcServerRequest();
}

void brcServerRequest() {
    Client thisClient = BRCServer.available();
    if (thisClient != null) {
      if (thisClient.available() > 0) {
        String request = thisClient.readString();
        if (request.indexOf("favicon") > 0) {  // do not respond to request for favicon
          return;
        }
        if (request.indexOf("BRC::") == -1) { // request for html page
          //println(request);
          //String html = String.join("\n",loadStrings(BRC_Controls));
          //html = html.substring(html.indexOf("<")); // remove first non_ASCII char
          //String sendit = brcServerResponse(html);
          //thisClient.write(sendit);
          //println(sendit);

          brcSendWebpage(thisClient);
          
        }
        else {   // incoming change of control variable
          int pos = request.indexOf("BRC::")+5;
          int pos2 = request.indexOf("::",pos);
          if (pos2 < 0) {
            thisClient.write(brcServerResponse("Bad request"));
            println("Bad request",request);
          }
          else {
            String payload = request.substring(pos,pos2).trim();
            payload = brcDecode(payload);
            String response = brcParseRequest(payload);
            thisClient.write(brcServerResponse(response));
            //println("payload",payload);
          }
        }
        
      }
    }
}

String brcServerResponse(String s) {
  return (String.format("HTTP/1.1 200 OK\nContent-Length: %d\nContent-Type: text/html\n\n%s",s.length(),s));
}  

String brcParseRequest(String payload) {
    boolean found = false;
    int i;
    
  // if "MONITORS"
  if (payload.equals("MONITORS"))
      return brcMonitorsResponse();
      
  // otherwise should be name=value   
  int pos = payload.indexOf("=");
  if (pos < 0) {return "Bad request, no =";}
  String id = new String(payload.substring(0,pos));
  String value = new String(payload.substring(pos+1));
  if (BRC_ShowMessages)
      println(id+"="+value);
  for (i = 0; i < BRC_ids.length; ++i) {
    if (id.equals(BRC_ids[i])){
      BRC_values[i] = value;
      BRC_changed.add(id);
      found = true;
      break;
    }
  }
  if (!found)
      return "ID not found: |"+payload+"|";
  return brcMonitorsResponse();
}

String brcMonitorsResponse() {
  String mResponse = "**";
  if (BRC_Monitors.length == 0)
      return "OK";
  for (int i = 0; i < BRC_Monitors.length; ++i) {
      mResponse += BRC_Monitors[i]+"="+BRC_MonitorValues[i];
      if (i != BRC_Monitors.length - 1)
         mResponse += "][";
  }
  return mResponse;
}

String brcChanged() {
  if (BRC_changed.size() == 0) {return "";}
  return BRC_changed.remove(0).toString();
}

String brcValue(String id) {
  for (int i = 0; i < BRC_ids.length; ++i) {
    if (id.equals(BRC_ids[i])) {return BRC_values[i];}
  }
  return "";
}

void brcSetMonitor(String monitorName, String monitorValue) {
  boolean found = false;
  for (int i = 0; i < BRC_Monitors.length; ++i)
    if (BRC_Monitors[i].equals(monitorName)) {
      BRC_MonitorValues[i] = monitorValue;
      found = true;
      break;
    }
  if (!found)
    println("Monitor name not found: "+monitorName);
}

void brcSetMonitor(String monitorName, int monitorValue) {
    brcSetMonitor(monitorName, str(monitorValue));
}

void brcSetMonitor(String monitorName, float monitorValue, int digitsPrecision) {
    String prec = "%."+str(digitsPrecision)+"f";
    String val = String.format(prec,monitorValue);
    brcSetMonitor(monitorName,val);
}

String brcDecode(String s) {
   int i, n1, n2;
   String out = "";
   char c;
   
     i = 0;
     while (i < s.length()) {
       c = s.charAt(i);
       if (c != '%' || i > (s.length()-3))
         out = out + c;
       else {
         n1 = brcHexVal((char) s.charAt(i+1));
         n2 = brcHexVal((char) s.charAt(i+2));
         if (n1 == -1 || n2 == -1)
           out = out + c;
         else {
           out = out + (char) (16*n1+n2);
           i += 2;
         }
       }
       //println(out+" "+i);
       ++i;
     }
   return out;
}

int brcHexVal(char c) {
  String hex = "0123456789ABCDEFabcdef";
  int i;
  for (i = 0; i < hex.length(); ++i) {
    if (c == hex.charAt(i)) {
      if (i <= 15)
        return i;
      else
        return i-6;
    }
  }
  return -1;
}

void brcShowMessages(boolean which) {
    BRC_ShowMessages = which;
}

// =============================== Webpage========================
String BRC_WebBody = 
"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n"
+ "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
+ "\n"
+ "<head>\n"
+ "<meta content=\"text/html; charset=utf-8\" http-equiv=\"Content-Type\" />\n"
+ "<title>BRC_Controls</title>\n"
+ "\n"
+ "<style type=\"text/css\">\n"
+ ".auto-style1 {\n"
+ "    border-color:red;\n"
+ "    border-width:1px;\n"
+ "    border-style:solid;\n"
+ "}\n"
+ ".monitor {\n"
+ "    border-color:blue;\n"
+ "    border-width:1px;\n"
+ "    border-style:solid;\n"
+ "}\n"
+ "</style>\n"
+ "\n"
+ "<script>\n"
+ "//----------------------- Sending --------------------------------------\n"
+ "function Send(url,results_id) {\n"
+ "  var xhttp = new XMLHttpRequest();\n"
+ "  xhttp.onreadystatechange = function() {\n"
+ "    //alert(url);\n"
+ "    if (this.readyState == 4 && this.status == 200) {\n"
+ "      if (this.responseText.slice(0,2) != \"**\")\n"
+ "         document.getElementById(results_id).innerHTML = this.responseText;\n"
+ "      else {\n"
+ "         var result = UpdateMonitors(this.responseText.slice(2));\n"
+ "         document.getElementById(results_id).innerHTML = result;\n"
+ "      }\n"
+ "    }\n"
+ "  };\n"
+ "  xhttp.open(\"GET\", url, true);\n"
+ "  xhttp.send(null);\n"
+ "}\n"
+ "\n"
+ "function SendNameValue(name_value) {\n"
+ "    var url = \"127.0.0.1:\" + Port + \"/BRC::\" + name_value + \"::\";\n"
+ "    Send(url,'results');\n"
+ "}\n"
+ "\n"
+ "// ---------------------------- Monitors ----------------------------\n"
+ "var MonitorTicker = null;\n"
+ "\n"
+ "function StartMonitors() {\n"
+ "    if (Monitor) {\n"
+ "        MonitorTicker = setInterval(MonitorRequest,250);   // every 1/2 second\n"
+ "    }\n"
+ "}\n"
+ "\n"
+ "function MonitorRequest() {\n"
+ "    SendNameValue(\"MONITORS\");\n"
+ "}\n"
+ "        \n"
+ "function UpdateMonitors(incoming) {\n"
+ "    var pairs = incoming.split(\"][\");\n"
+ "    var i, j, pair, found;\n"
+ "    for (i = 0; i < pairs.length; ++i) {\n"
+ "        found = false;\n"
+ "        pair = pairs[i].split(\"=\");\n"
+ "        for (j = 0; j < Controls.length; ++j) {\n"
+ "            if (Controls[j][2] == pair[0]) { \n"
+ "                document.getElementById(Controls[j][1]).innerHTML = \"&nbsp;\"+pair[1]+\"&nbsp;\";\n"
+ "                found = true;\n"
+ "                break;\n"
+ "            }\n"
+ "        }\n"
+ "        if (!found)\n"
+ "            return \"Monitor not found: \"+pair[0]\n"
+ "    }\n"
+ "    return \"OK\"\n"
+ "}\n"
+ "\n"
+ "// ---------------------------------------------- Sendall and RangesInit ------------------------------\n"
+ "\n"
+ "const Port = 10002;\n"
+ "\n"
+ "// needed by Sendall() and RangesInit\n"
+ "\n"
+ "/*\n"
+ "Typical controls:\n"
+ "const Controls=[[\"RADIO\",\"brc_1\",\"shade\"],[\"DROPDOWN\",\"brc_4\",\"color\"],[\"CHECKBOX\",\"brc_5\",\"grayscale\"],\n"
+ "                [\"RANGE\",\"brc_6\",\"size\",\"brc_7\"],[\"TEXT\",\"brc_8\",\"title\"]];\n"
+ "\n"
+ "*/\n"
+ "\n"
+ "const Controls=[[\"NOTE\",\"brc_1\",\"nt1\"],\n"
+ "[\"CHECKBOX\",\"brc_2\",\"cameraOn\"],\n"
+ "[\"TEXT\",\"brc_3\",\"fileName\"],\n"
+ "[\"BUTTON\",\"brc_4\",\"init\"],\n"
+ "[\"NOTE\",\"brc_5\",\"nt2\"],\n"
+ "[\"DROPDOWN\",\"brc_6\",\"object\"],\n"
+ "[\"BUTTON\",\"brc_7\",\"faceRecognition\"],\n"
+ "[\"NOTE\",\"brc_8\",\"nt3\"],\n"
+ "[\"RANGE\",\"brc_9\",\"brightness\",\"brc_10\"],\n"
+ "[\"BUTTON\",\"brc_11\",\"adjustBrightness\"],\n"
+ "[\"NOTE\",\"brc_12\",\"nt4\"],\n"
+ "[\"RANGE\",\"brc_13\",\"contrast\",\"brc_14\"],\n"
+ "[\"BUTTON\",\"brc_15\",\"adjustContrast\"],\n"
+ "[\"NOTE\",\"brc_16\",\"nt5\"],\n"
+ "[\"DROPDOWN\",\"brc_17\",\"filter\"],\n"
+ "[\"RANGE\",\"brc_18\",\"thresholdValue\",\"brc_19\"],\n"
+ "[\"RANGE\",\"brc_20\",\"blurValue\",\"brc_21\"],\n"
+ "[\"RANGE\",\"brc_22\",\"adaptiveBlockSize\",\"brc_23\"],\n"
+ "[\"RANGE\",\"brc_24\",\"adaptiveConstant\",\"brc_25\"],\n"
+ "[\"BUTTON\",\"brc_26\",\"imageFilter\"],\n"
+ "[\"NOTE\",\"brc_27\",\"nt6\"],\n"
+ "[\"BUTTON\",\"brc_28\",\"findContours\"],\n"
+ "[\"RANGE\",\"brc_29\",\"contourThreshold\",\"brc_30\"],\n"
+ "[\"NOTE\",\"brc_31\",\"nt7\"],\n"
+ "[\"DROPDOWN\",\"brc_32\",\"filterType\"],\n"
+ "[\"BUTTON\",\"brc_33\",\"findEdges\"],\n"
+ "[\"NOTE\",\"brc_34\",\"nt8\"],\n"
+ "[\"BUTTON\",\"brc_35\",\"findLines\"],\n"
+ "[\"RANGE\",\"brc_36\",\"findLinesThreshold\",\"brc_37\"],\n"
+ "[\"RANGE\",\"brc_38\",\"findLinesMinLength\",\"brc_39\"],\n"
+ "[\"RANGE\",\"brc_40\",\"findLinesMaxLineGap\",\"brc_41\"],\n"
+ "[\"NOTE\",\"brc_42\",\"nt9\"],\n"
+ "[\"BUTTON\",\"brc_43\",\"backgroundSubtraction\"],\n"
+ "[\"NOTE\",\"brc_44\",\"nt10\"],\n"
+ "[\"BUTTON\",\"brc_45\",\"colorChannels\"]];\n"
+ "\n"
+ "Monitor = false;\n"
+ "\n"
+ "function Sendall() {\n"
+ "    var i, opt;\n"
+ "    \n"
+ "    for (i = 0; i < Controls.length; ++i) {\n"
+ "        if (Controls[i][0] == \"RADIO\") {\n"
+ "            var rads = document.getElementsByName(Controls[i][1]);\n"
+ "            for (opt = 0; opt < rads.length; ++opt) {\n"
+ "                if (rads[opt].checked)\n"
+ "                    SendNameValue(Controls[i][2]+\"=\"+rads[opt].value);\n"
+ "            }\n"
+ "        }\n"
+ "        else if (Controls[i][0] == \"DROPDOWN\" || Controls[i][0] == \"TEXT\") {\n"
+ "            SendNameValue(Controls[i][2]+\"=\"+document.getElementById(Controls[i][1]).value);\n"
+ "        }\n"
+ "        else if (Controls[i][0] == \"CHECKBOX\") {\n"
+ "            if (document.getElementById(Controls[i][1]).checked)\n"
+ "                SendNameValue(Controls[i][2]+\"=true\");\n"
+ "            else\n"
+ "                SendNameValue(Controls[i][2]+\"=false\");\n"
+ "        }\n"
+ "        else if (Controls[i][0] == \"RANGE\") {\n"
+ "            ShowRange(Controls[i][1],Controls[i][3],Controls[i][2]);\n"
+ "        }\n"
+ "    }\n"
+ "}\n"
+ "\n"
+ "\n"
+ "\n"
+ "// ------------------------------------ Individual senders ---------------------------------\n"
+ "function SendRadio(name_value) {\n"
+ "    //alert(name_value);\n"
+ "    SendNameValue(name_value);\n"
+ "}\n"
+ "\n"
+ "function SendCheckbox(id,brc_name) {\n"
+ "    if (document.getElementById(id).checked)\n"
+ "        SendNameValue(brc_name+'=true');\n"
+ "    else\n"
+ "        SendNameValue(brc_name+'=false');\n"
+ "}\n"
+ "\n"
+ "// ---------------------------------------- Utility functions -------------------------------\n"
+ "\n"
+ "function ShowRange(range_id,output_id,brc_name) {\n"
+ "    document.getElementById(output_id).innerHTML = document.getElementById(range_id).value;\n"
+ "    SendNameValue(brc_name+\"=\"+document.getElementById(range_id).value);\n"
+ "}\n"
+ "\n"
+ "\n"
+ "\n"
+ "</script>\n"
+ "\n"
+ "</head>\n"
+ "\n"
+ "<body onLoad=\"StartMonitors();\">\n"
+ "<form name=\"brc\">\n"
+ "\n"
+ "<table cellpadding=\"3\"><tr><td>\n"
+ "<table cellspacing=\"0\" ><tr><td>BRC Web Controls: &nbsp;&nbsp; </td>\n"
+ "<td class=\"auto-style1\"><label id=\"results\">OK</label></td></tr></table></td>\n"
+ "<td><input type=\"button\" name=\"sendall\" id=\"sendall\" value=\"Send all\" onclick=\"Sendall();\"/></td></tr></table>\n"
+ "\n"
+ "<br/>\n"
+ "<table><tr><td class=\"auto-style1\"><label id=\"brc_1\">You must use either your Camera or enter a file to run commands</label></td></tr></table>\n"
+ "\n"
+ "<table ><tr><td class=\"auto-style1\">\n"
+ "Turn Camera On:  <input name=\"brc_2\" type=\"checkbox\"  id=\"brc_2\" onclick=\"SendCheckbox('brc_2','cameraOn');\"/> \n"
+ "</td></tr></table>\n"
+ "\n"
+ "<table ><tr><td class=\"auto-style1\">\n"
+ "File Name: <input type=\"text\" name=\"brc_3\" id=\"brc_3\" onchange=\"SendNameValue('fileName='+document.getElementById('brc_3').value);\" /> \n"
+ "</td></tr></table>\n"
+ "\n"
+ "<input type=\"button\" name=\"<!--<id>-->\" id=\"<!--<id>-->\" value=\"Initialize\" onClick=\"SendNameValue('init='+Math.floor(Math.random()*1000000));\" />\n"
+ "&nbsp;&nbsp;&nbsp;\n"
+ "\n"
+ " <table><tr><td class=\"auto-style1\"><label id=\"brc_5\">Object Recognition</label></td></tr></table>\n"
+ "\n"
+ "<table ><tr><td class=\"auto-style1\">Object to Detect:&nbsp;&nbsp;&nbsp;\n"
+ "<select name=\"brc_6\" id=\"brc_6\" onchange=\"SendNameValue('object='+document.brc.brc_6.value);\">\n"
+ "<option selected=\"selected\" value=\"face\">Face</option>\n"
+ "<option  value=\"eye\">Eye</option>\n"
+ "<option  value=\"mouth\">Mouth</option>\n"
+ "<option  value=\"nose\">Nose</option>\n"
+ "<option  value=\"rightEar\">Right Ear</option>\n"
+ "</select></td></tr></table>\n"
+ "\n"
+ "<input type=\"button\" name=\"<!--<id>-->\" id=\"<!--<id>-->\" value=\"Object Recognition\" onClick=\"SendNameValue('faceRecognition='+Math.floor(Math.random()*1000000));\" />\n"
+ "&nbsp;&nbsp;&nbsp;\n"
+ "\n"
+ " <table><tr><td class=\"auto-style1\"><label id=\"brc_8\">brightness</label></td></tr></table>\n"
+ "\n"
+ "<table ><tr><td class=\"auto-style1\">-255  \n"
+ "    <input type=\"range\" id=\"brc_9\" name=\"brc_9\" min=\"-255\" max=\"255\" value=\"50\" step=\"1\"\n"
+ "    oninput=\"ShowRange('brc_9','brc_10','brightness');\" />  255<br/>\n"
+ "    Brightness: <label id=\"brc_10\"></label>\n"
+ "    </td></tr></table>\n"
+ "\n"
+ "<input type=\"button\" name=\"<!--<id>-->\" id=\"<!--<id>-->\" value=\"Adjust Brightness\" onClick=\"SendNameValue('adjustBrightness='+Math.floor(Math.random()*1000000));\" />\n"
+ "&nbsp;&nbsp;&nbsp;\n"
+ "\n"
+ " <table><tr><td class=\"auto-style1\"><label id=\"brc_12\">contrast</label></td></tr></table>\n"
+ "\n"
+ "<table ><tr><td class=\"auto-style1\">0  \n"
+ "    <input type=\"range\" id=\"brc_13\" name=\"brc_13\" min=\"0\" max=\"400\" value=\"0\" step=\"1\"\n"
+ "    oninput=\"ShowRange('brc_13','brc_14','contrast');\" />  400<br/>\n"
+ "    Contrast: <label id=\"brc_14\"></label>\n"
+ "    </td></tr></table>\n"
+ "\n"
+ "<input type=\"button\" name=\"<!--<id>-->\" id=\"<!--<id>-->\" value=\"Adjust Contrast\" onClick=\"SendNameValue('adjustContrast='+Math.floor(Math.random()*1000000));\" />\n"
+ "&nbsp;&nbsp;&nbsp;\n"
+ "\n"
+ " <table><tr><td class=\"auto-style1\"><label id=\"brc_16\">Image Filtering</label></td></tr></table>\n"
+ "\n"
+ "<table ><tr><td class=\"auto-style1\">Filter Type:&nbsp;&nbsp;&nbsp;\n"
+ "<select name=\"brc_17\" id=\"brc_17\" onchange=\"SendNameValue('filter='+document.brc.brc_17.value);\">\n"
+ "<option selected=\"selected\" value=\"t\">threshold</option>\n"
+ "<option  value=\"b\">blur</option>\n"
+ "<option  value=\"a\">adaptive</option>\n"
+ "</select></td></tr></table>\n"
+ "\n"
+ "<table ><tr><td class=\"auto-style1\">1  \n"
+ "    <input type=\"range\" id=\"brc_18\" name=\"brc_18\" min=\"1\" max=\"255\" value=\"80\" step=\"1\"\n"
+ "    oninput=\"ShowRange('brc_18','brc_19','thresholdValue');\" />  255<br/>\n"
+ "    Threshold Value: <label id=\"brc_19\"></label>\n"
+ "    </td></tr></table>\n"
+ "\n"
+ "<table ><tr><td class=\"auto-style1\">1  \n"
+ "    <input type=\"range\" id=\"brc_20\" name=\"brc_20\" min=\"1\" max=\"255\" value=\"50\" step=\"1\"\n"
+ "    oninput=\"ShowRange('brc_20','brc_21','blurValue');\" />  255<br/>\n"
+ "    Blur Amount: <label id=\"brc_21\"></label>\n"
+ "    </td></tr></table>\n"
+ "\n"
+ "<table ><tr><td class=\"auto-style1\">3  \n"
+ "    <input type=\"range\" id=\"brc_22\" name=\"brc_22\" min=\"3\" max=\"255\" value=\"51\" step=\"2\"\n"
+ "    oninput=\"ShowRange('brc_22','brc_23','adaptiveBlockSize');\" />  255<br/>\n"
+ "    Adaptive Block Size: <label id=\"brc_23\"></label>\n"
+ "    </td></tr></table>\n"
+ "\n"
+ "<table ><tr><td class=\"auto-style1\">1  \n"
+ "    <input type=\"range\" id=\"brc_24\" name=\"brc_24\" min=\"1\" max=\"255\" value=\"50\" step=\"1\"\n"
+ "    oninput=\"ShowRange('brc_24','brc_25','adaptiveConstant');\" />  255<br/>\n"
+ "    Adaptive Constant: <label id=\"brc_25\"></label>\n"
+ "    </td></tr></table>\n"
+ "\n"
+ "<input type=\"button\" name=\"<!--<id>-->\" id=\"<!--<id>-->\" value=\"Image Filter\" onClick=\"SendNameValue('imageFilter='+Math.floor(Math.random()*1000000));\" />\n"
+ "&nbsp;&nbsp;&nbsp;\n"
+ "\n"
+ " <table><tr><td class=\"auto-style1\"><label id=\"brc_27\">Finding Contours</label></td></tr></table>\n"
+ "\n"
+ "<input type=\"button\" name=\"<!--<id>-->\" id=\"<!--<id>-->\" value=\"Find Contours\" onClick=\"SendNameValue('findContours='+Math.floor(Math.random()*1000000));\" />\n"
+ "&nbsp;&nbsp;&nbsp;\n"
+ "\n"
+ " <table ><tr><td class=\"auto-style1\">1  \n"
+ "    <input type=\"range\" id=\"brc_29\" name=\"brc_29\" min=\"1\" max=\"255\" value=\"80\" step=\"1\"\n"
+ "    oninput=\"ShowRange('brc_29','brc_30','contourThreshold');\" />  255<br/>\n"
+ "    Contour Threshold: <label id=\"brc_30\"></label>\n"
+ "    </td></tr></table>\n"
+ "\n"
+ "<table><tr><td class=\"auto-style1\"><label id=\"brc_31\">Edge Finder</label></td></tr></table>\n"
+ "\n"
+ "<table ><tr><td class=\"auto-style1\">Filter Type:&nbsp;&nbsp;&nbsp;\n"
+ "<select name=\"brc_32\" id=\"brc_32\" onchange=\"SendNameValue('filterType='+document.brc.brc_32.value);\">\n"
+ "<option selected=\"selected\" value=\"canny\">Canny</option>\n"
+ "<option  value=\"scharr\">Scharr</option>\n"
+ "<option  value=\"sobel\">Sobel</option>\n"
+ "</select></td></tr></table>\n"
+ "\n"
+ "<input type=\"button\" name=\"<!--<id>-->\" id=\"<!--<id>-->\" value=\"Find Edges\" onClick=\"SendNameValue('findEdges='+Math.floor(Math.random()*1000000));\" />\n"
+ "&nbsp;&nbsp;&nbsp;\n"
+ "\n"
+ " <table><tr><td class=\"auto-style1\"><label id=\"brc_34\">Find Lines using Hough line Detection</label></td></tr></table>\n"
+ "\n"
+ "<input type=\"button\" name=\"<!--<id>-->\" id=\"<!--<id>-->\" value=\"Find Lines\" onClick=\"SendNameValue('findLines='+Math.floor(Math.random()*1000000));\" />\n"
+ "&nbsp;&nbsp;&nbsp;\n"
+ "\n"
+ " <table ><tr><td class=\"auto-style1\">1  \n"
+ "    <input type=\"range\" id=\"brc_36\" name=\"brc_36\" min=\"1\" max=\"255\" value=\"100\" step=\"1\"\n"
+ "    oninput=\"ShowRange('brc_36','brc_37','findLinesThreshold');\" />  255<br/>\n"
+ "    Threshold: <label id=\"brc_37\"></label>\n"
+ "    </td></tr></table>\n"
+ "\n"
+ "<table ><tr><td class=\"auto-style1\">10  \n"
+ "    <input type=\"range\" id=\"brc_38\" name=\"brc_38\" min=\"10\" max=\"100\" value=\"30\" step=\"1\"\n"
+ "    oninput=\"ShowRange('brc_38','brc_39','findLinesMinLength');\" />  100<br/>\n"
+ "    Minimum Length: <label id=\"brc_39\"></label>\n"
+ "    </td></tr></table>\n"
+ "\n"
+ "<table ><tr><td class=\"auto-style1\">10  \n"
+ "    <input type=\"range\" id=\"brc_40\" name=\"brc_40\" min=\"10\" max=\"100\" value=\"20\" step=\"1\"\n"
+ "    oninput=\"ShowRange('brc_40','brc_41','findLinesMaxLineGap');\" />  100<br/>\n"
+ "    Maximum Line Gap: <label id=\"brc_41\"></label>\n"
+ "    </td></tr></table>\n"
+ "\n"
+ "<table><tr><td class=\"auto-style1\"><label id=\"brc_42\">Background Subtraction</label></td></tr></table>\n"
+ "\n"
+ "<input type=\"button\" name=\"<!--<id>-->\" id=\"<!--<id>-->\" value=\"Background Subtration\" onClick=\"SendNameValue('backgroundSubtraction='+Math.floor(Math.random()*1000000));\" />\n"
+ "&nbsp;&nbsp;&nbsp;\n"
+ "\n"
+ " <table><tr><td class=\"auto-style1\"><label id=\"brc_44\">Color Channeling</label></td></tr></table>\n"
+ "\n"
+ "<input type=\"button\" name=\"<!--<id>-->\" id=\"<!--<id>-->\" value=\"Color Channels\" onClick=\"SendNameValue('colorChannels='+Math.floor(Math.random()*1000000));\" />\n"
+ "&nbsp;&nbsp;&nbsp;\n"
+ "\n"
+ " \n"
+ "\n"
+ "</form>\n"
+ "</body>\n"
+ "</html>\n";

// =============================== End webpage ===================
void brcSendWebpage(Client client) {
    String head1 = "HTTP/1.1 200 OK\nContent-Length: ";
    String head2 = "\nContent-Type: text/html\n\n";
    String WebPage = head1+str(BRC_WebBody.length())+head2+BRC_WebBody;
    client.write(WebPage);
}
