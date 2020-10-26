public without sharing class PSFieldHistoryTimerUtils {
    @AuraEnabled
    public static String getFieldHistory(String recordId, String fieldApiName)
    {
        Map<String, Object> resp = new Map<String, Object>();

        String objName = ID.valueOf(recordId).getSObjectType().getDescribe().getName();
        String histObjName;
        String parentIdField;
        resp.put('objectName', objName);

        Schema.DescribeFieldResult fieldRes = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldApiName).getDescribe() ;
        resp.put('fieldName', fieldRes.getName());

        if (objName.endsWith('__c'))
        {
            histObjName = objName.substringBefore('__c') + '__History';
            parentIdField = 'ParentId';
        }
        else {
            histObjName = objName + 'History';
            parentIdField = objName + 'Id';
        }

        Map<String, String> fieldMap = getPickListMap(objName, fieldApiName);

        String soql = 'SELECT ' + fieldApiName + ', CreatedDate, CreatedBy.Name, LastModifiedDate FROM ' + objName + ' WHERE Id=\'' + recordId + '\'';
        System.debug('soql=' + soql);
        List<SObject> objList = Database.query(soql);

        soql = 'SELECT Id, CreatedDate, CreatedBy.Name, NewValue, OldValue FROM ' + histObjName +
               ' WHERE Field=\'' + fieldApiName + '\' AND ' + parentIdField + '=\'' + recordId + '\' ORDER BY CreatedDate DESC';
        System.debug('soql=' + soql);
        List<SObject> histList = Database.query(soql);

        if (histList == null || histList.size() == 0)
        {
            Map<String,Object> tmpE = new Map<String,Object>();
            resp.put('currValue', getMapLabel((String)objList[0].get(fieldApiName), fieldMap) );
            resp.put('currDate', objList[0].get('LastModifiedDate'));
            resp.put('currDateFormat', ((DateTime)objList[0].get('LastModifiedDate')).format());
            resp.put('currDuration', getDuration((DateTime)objList[0].get('CreatedDate'), DateTime.now()));
        }
        else {
            List<Map<String,Object>> tmpHistList = new List<Map<String,Object>>();
            Integer i = 0;

            for (SObject hist : histList)
            {
                System.debug('hist=' + JSON.serializePretty(hist));

                Map<String,Object> tmpE = new Map<String,Object>();
                tmpE.put('id', hist.get('Id'));
                tmpE.put('value', getMapLabel((String)hist.get('OldValue'), fieldMap));

                if (i == 0)
                {
                    resp.put('currValue', getMapLabel((String)hist.get('NewValue'), fieldMap));
                    resp.put('currDate', hist.get('CreatedDate'));
                    resp.put('currDateFormat', ((DateTime)hist.get('CreatedDate')).format());
                    resp.put('currDuration', getDuration((DateTime)hist.get('CreatedDate'), DateTime.now()));
                }

                if (i == histList.size()-1)
                {
                    tmpE.put('createdDate', ((DateTime)objList[0].get('CreatedDate')).format());
                    tmpE.put('createdBy', getSobjectValue(objList[0], 'CreatedBy.Name'));
                    tmpE.put('duration', getDuration((DateTime)objList[0].get('CreatedDate'), (DateTime)hist.get('CreatedDate')));
                }
                else {
                    SObject nextE = histList[i+1];

                    tmpE.put('createdDate', ((DateTime)nextE.get('CreatedDate')).format());
                    tmpE.put('createdBy', getSobjectValue(nextE, 'CreatedBy.Name'));
                    tmpE.put('duration', getDuration((DateTime)nextE.get('CreatedDate'), (DateTime)hist.get('CreatedDate')));
                }

/*
                //tmpE.put('createdDate', hist.get('CreatedDate'));
                //tmpE.put('createdBy', getSobjectValue(hist, 'CreatedBy.Name'));
                //tmpE.put('newValue', getMapLabel((String)hist.get('NewValue'), fieldMap));
                //tmpE.put('oldValue', getMapLabel((String)hist.get('OldValue'), fieldMap));
                tmpE.put('value', getMapLabel((String)hist.get('OldValue'), fieldMap));
                tmpE.put('duration', '');

                if (i == histList.size()-1)
                {
                    resp.put('currValue', getMapLabel((String)hist.get('NewValue'), fieldMap));
                    resp.put('currDate', hist.get('CreatedDate'));
                    resp.put('currDuration', getDuration((DateTime)hist.get('CreatedDate'), DateTime.now()));
                }

                if (i > 0)
                {
                    Map<String,Object> prevE = tmpHistList[i-1];
                    prevE.put('duration', getDuration((DateTime)prevE.get('createdDate'), (DateTime)hist.get('CreatedDate')));
                    tmpE.put('createdDate', hist.get('CreatedDate'));
                    tmpE.put('createdBy', getSobjectValue(hist, 'CreatedBy.Name'));
                } else if (i = 0) {
                    
                }
*/
                tmpHistList.add(tmpE);
                
                i++;
            }
            resp.put('history', tmpHistList);

        }

        return JSON.serializePretty(resp);
    }

    public static String getMapLabel(String key, Map<String, String> fieldMap)
    {
        if (fieldMap == null) return key;

        if (fieldMap.containsKey(key))
        {
            return fieldMap.get(key);
        }
        else {
            return key;
        }
    }

    /*
    public static String getLength(DateTime startDate, DateTime endDate)
    {
        Long diffTime = endDate.getTime() - startDate.getTime();

        Integer days = (Integer)(difftime / (86400000);
    }
    */

    public static String getDuration(DateTime start_date_time, DateTime end_date_time) {
        Integer start_year_as_int = start_date_time.year(); //grab the start year
        Integer start_day_as_int = start_date_time.dayOfYear(); //grab the start day
        Integer start_hour_as_int = start_date_time.hour(); //grab the start hour
        Integer start_minute_as_int = start_date_time.minute(); //grab the start minute
        Integer start_second_as_int = start_date_time.second(); //grab the start second
        Integer start_in_seconds = (start_year_as_int * 31556926) + (start_day_as_int * 86400) + (start_hour_as_int * 3600) + (start_minute_as_int * 60) + (start_second_as_int * 1); //convert the start date to a value in seconds
        //there are 31556926 seconds in one year and that is why we are mutiplying the start_year_as_int value by 31556926 > this same logic applies to the days, hours & minutes logic which is why there are weird multipliers in that line of code
        Integer end_year_as_int = end_date_time.year(); //grab the end year
        Integer end_day_as_int = end_date_time.dayOfYear(); //grab the end day
        Integer end_hour_as_int = end_date_time.hour(); //grab the end hour
        Integer end_minute_as_int = end_date_time.minute(); //grab the end minute
        Integer end_second_as_int = end_date_time.second(); //grab the end second
        Integer end_in_seconds = (end_year_as_int * 31556926) + (end_day_as_int * 86400) + (end_hour_as_int * 3600) + (end_minute_as_int * 60) + (end_second_as_int * 1); //convert the end date to a value in seconds
        Integer total_duration_in_seconds = end_in_seconds - start_in_seconds; //duration in seconds
        Integer year_result = math.mod(math.floor(total_duration_in_seconds/31556926).intValue(),10000000); //number of years
        Integer day_result = math.mod(math.floor(total_duration_in_seconds/86400).intValue(),365); //number of days
        Integer hour_result = math.mod(math.floor(total_duration_in_seconds/3600).intValue(),24); //number of hours
        Integer minute_result = math.mod(math.floor(total_duration_in_seconds/60).intValue(),60); //number of minutes
        Integer second_result = math.mod(math.floor(total_duration_in_seconds/1).intValue(),60); //number of seconds

        String year_text_string = segment_text('y', year_result, ''); //string variable for text regarding Year
        String day_text_string = segment_text('d', day_result, year_text_string); //string variable for text regarding Day
        String hour_text_string = segment_text('h', hour_result, year_text_string + day_text_string); //string variable for text regarding Hour
        String minute_text_string = segment_text('m', minute_result, year_text_string + day_text_string + hour_text_string); //string variable for text regarding Minute
        String second_text_string = segment_text('s', second_result, year_text_string + day_text_string + hour_text_string + minute_text_string); //string variable for text regarding Second
        String return_string = year_text_string + day_text_string + hour_text_string + minute_text_string + second_text_string;//concatenate all the strings into one for our resutling test string
        return return_string.trim(); //pass back the final string
    }

    public static String segment_text(String segment_string, Integer segment_integer, String prior_segments) {
        String return_string; //string for returning
        String spacer = ''; //string for holding an additional spacer
        if (segment_string != 's') { //if the segment being determined is not Seconds
            spacer = ' '; //create a spacer value
        }

        if (segment_integer > 9) { //if the value is greater than 1
            return_string = segment_integer.format()+segment_string+spacer; //format
        } else if (segment_integer > 0) { //if the value is greater than 0
            return_string = ' ' + segment_integer.format()+segment_string+spacer; //format
        } else { //otherwise
            if (prior_segments != '' || segment_string == 's') { //if there is a value for prior segments or this is the seconds segment
                return_string = '0'+segment_string+spacer; //format
            } else {
                return_string = ''; //set variable to null
            }
        }

        /*
        if (segment_integer > 1) { //if the value is greater than 1
        	return_string = segment_integer.format()+''+segment_string+spacer; //format
        } else if (segment_integer > 0) { //if the value is greater than 0
        	return_string = segment_integer.format()+''+segment_string+spacer; //format
        } else { //otherwise
        	if (prior_segments != '' || segment_string == 's') { //if there is a value for prior segments or this is the seconds segment
        		return_string = '0'+segment_string+spacer; //format
        	} else {
        		return_string = ''; //set variable to null
        	}
        }
        */
        System.debug('return_string=\'' + return_string + '\'');
        return return_string; //pass back the string
    }

    public static Map<String,String> getPickListMap(String objectName, String fieldName)
    {
        Map<String,String> resp = null;

        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();

        System.debug('type=' + fieldResult.type);
        if (fieldResult.type.name() == 'PICKLIST')
        {
          List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
          resp = new Map<String,String>();
          for( Schema.PicklistEntry pickListVal : ple) {
              resp.put(pickListVal.getValue(), pickListVal.getLabel());
          }
        }

        return resp;
    }

    public static Object getSobjectValue(SObject obj, String fieldname)
    {
        Object retVal;

        if (fieldname.indexOf('.') != -1)
        {
            List<String> flds = fieldname.split('\\.');
            Integer i=1;

            for (String fld : flds)
            {
                if (obj == null) return null;

                if (i++ == flds.size())
                {
                    retVal = obj.get(fld);
                }
                else {
                    obj = (SObject)obj.getSObject(fld);
                }
            }

        }
        else {
            retVal = obj.get(fieldname);
        }

        return retVal;
    }
}