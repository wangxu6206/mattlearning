/**
*
* @author Peter Pham
* @description a utility to create a parent-child thread/queue
*
*/
component output="false"
{

	public function init(required any Logging)
	{
		variables._Logging = arguments.Logging;
		return this;
	}


	/**
	 * @hint create a queue (a parent-child thread) to execute time consuming function
	 * The current request calling this function is the parent thread
	 */
	public any function create(required string queue_name, required numeric parent_timeout, required numeric child_timeout, required string child_executing_function, struct child_executing_params, required any child_scope)
	{
		var parentThread_start = getTickCount();
		var threadname = 'child_#arguments.queue_name#';
		var stReturn = {'thread'={}};

		setting requestTimeOut=arguments.parent_timeout;
		_Logging.write(text="Parent thread - #arguments.queue_name# - START - Request time out = #arguments.parent_timeout#s", type="Information", group="queue");

		// create child thread
		lock name=threadname timeout=arguments.child_timeout type="exclusive" {

			thread name=threadname action="run" params=arguments.child_executing_params functionscope=arguments.child_scope executingfunction=arguments.child_executing_function child_timeout=arguments.child_timeout
			{
				thread.params = attributes.params;

				// set request time out for child thread
				setting requestTimeOut=attributes.child_timeout;
				_Logging.write(text="Child thread: - #thread.name# - START - Request time out = #attributes.child_timeout#s", type="Information", group="queue");

				// call executing function
				attributes.functionscope[attributes.executingfunction](argumentCollection=thread.params);
			}

		}

		// wait for child thread
		threadjoin(name=threadname);

		// log child thread information
		_Logging.write(text="Child thread - #threadname# - END - Status = #cfthread[threadname].STATUS# - Time taken = #cfthread[threadname].ELAPSEDTIME#", type="Information", group="queue");
		stReturn['thread'] = duplicate(cfthread[threadname]);

		// finish parent thread
		_Logging.write(text="Parent thread - #threadname# - Time taken = #getTickCount()-parentThread_start#ms", type="Information", group="queue");

		if (cfthread[threadname].STATUS is "TERMINATED" AND StructKeyExists(cfthread[threadname],'ERROR')){
			// an error occured on child thread
			_Logging.write(text="Child thread - #threadname# - message: #cfthread[threadname].ERROR.message# - detail: #cfthread[threadname].ERROR.detail#");
			throw(type="queue.error", message="#cfthread[threadname].ERROR.message#", detail=cfthread[threadname].ERROR.detail, extendedInfo=serializeJSON(cfthread[threadname].ERROR)) ;
		}

		return stReturn;
	}

}