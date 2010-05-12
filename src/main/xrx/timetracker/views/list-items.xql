xquery version "1.0";


import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";
import module namespace util="http://exist-db.org/xquery/util";

declare option exist:serialize "method=xhtml media-type=text/xml";


declare function local:main() as node() * {
    let $from := request:get-parameter("from", "1970-01-01")
    let $to := request:get-parameter("to", "2020-01-01")

    for $task in collection('/db/betterform/apps/timetracker/data/task')//task
        let $task-date := $task/date
        let $task-created := $task/created
        let $dur := $task/duration
        where $task-date >= $from and $task-date <= $to
        order by $task-date descending
        return
            <tr>
                <td>{$task-date}</td>
                <td>{$task/project}</td>
                <td>{$task/who}</td>
                <td>{data($task/duration/@hours)}:{data($task/duration/@minutes)}</td>
                <td>{$task/what}</td>
                <td>{$task/note}</td>
                <td>{$task/billable}</td>
                <td>{$task/status}</td>
                <td><a href="javascript:dojo.publish('/task/edit',['{$task-created}']);">edit</a></td>
                <td><a href="javascript:dojo.publish('/task/delete',['{$task-created}']);">delete</a></td>
            </tr>
};

declare function local:getTasks() as node() * {
    let $from := request:get-parameter("from", "1970-01-01")
    let $to := request:get-parameter("to", "2020-01-01")

    for $task in collection('/db/betterform/apps/timetracker/data/task')//task
        let $task-date := $task/date
        let $dur := $task/duration
        where $task-date >= $from and $task-date <= $to
        order by $task-date descending
        return $task
};

(: convert all hours to minutes :)
declare function local:hours-in-minutes($tasks as node()*) as xs:integer
{
  let $sum := sum($tasks//duration/@hours)
  return  $sum * 60
};

(: produces the billing nodes. Uses the dailyrate of 850:)
declare function local:billing ($hours as xs:integer, $minutes as xs:integer)
as element()
{
   local:billing($hours, $minutes, 850)
};

declare function local:billing($hours as xs:integer, $minutes as xs:integer, $dailyRate as xs:integer)
as element()
{
    let $hourlyRate   := $dailyRate div 8
    let $nettoHours   := $hours * $hourlyRate
    let $nettoMinutes := ($minutes div 60) * $hourlyRate
    return
	<billing>
          <dailyRate>{$dailyRate}</dailyRate>
          <hourlyRate>{$hourlyRate}</hourlyRate>
          <nettoHours>{$nettoHours}</nettoHours>
          <nettoMinutes>{$nettoMinutes}</nettoMinutes>
          <bill>€ {$nettoHours + $nettoMinutes}</bill>
	</billing>
};


declare function local:sumTasks()  {

  let $tasks             := local:getTasks()
  let $hoursInMinutes    := local:hours-in-minutes($tasks)
  let $totalMinutes      := $hoursInMinutes + sum($tasks//duration/@minutes)
  let $totalHours        := $totalMinutes idiv 60
  let $remainingMinutes  := $totalMinutes mod 60
  let $totalTime         := concat($totalHours,':',$remainingMinutes)
  let $days              := $totalHours idiv 8


  return $totalTime

};
(: produces a list of tasks filtered http parameters :)
declare function local:project() as element()?
{
  let $tasks             := local:getTasks()
  let $hoursInMinutes    := local:hours-in-minutes($tasks)
  let $totalMinutes      := $hoursInMinutes + sum($tasks//duration/@minutes)
  let $totalHours        := $totalMinutes idiv 60
  let $remainingMinutes  := $totalMinutes mod 60
  let $totalTime         := concat($totalHours,':',$remainingMinutes)
  let $days              := $totalHours div 8

  return
    <table id="summary" >
        <tr class="tableHeader">
            <td class="summaryLabel">Days</td>
            <td class="summaryValue">{$days}</td>
            <td class="summaryLabel">Total Time</td>
            <td class="summaryValue">{$totalTime}</td>
        </tr>
   </table>
};

request:set-attribute("betterform.filter.parseResponseBody", "true"),
<html   xmlns="http://www.w3.org/1999/xhtml"
        xmlns:ev="http://www.w3.org/2001/xml-events">
   <head>
      <title>All Tasks</title>
      <link rel="stylesheet" type="text/css"
                href="/exist/rest/db/betterform/apps/timetracker/resources/timetracker.css"/>

    </head>
    <body>
    	<div id="dataTable">
		   <table id="taskTable">
			 <tr>
				<th>Date</th>
				<th>Project</th>
				<th>Who</th>
				<th>Duration</th>
				<th>What</th>
				<th>Note</th>
				<th>Billable</th>
				<th>Status</th>
				<th colspan="2"> </th>
			 </tr>
			 {local:main()}
		 </table>
       {local:project()}
	 </div>
    </body>
</html>
