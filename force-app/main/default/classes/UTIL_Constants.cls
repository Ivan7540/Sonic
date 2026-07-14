public class UTIL_Constants 
{
    public static final Integer DAYS_IN_YEAR = 365;
	public static final Integer HOURS_PER_DAY = 24;
	public static final Integer WORKING_HOURS_PER_DAY = 8;
	public static final Integer MILLISECONDS_PER_HOUR = 1000 * 60 * 60;
	public static final Integer MS_PER_WORKING_DAY = WORKING_HOURS_PER_DAY * MILLISECONDS_PER_HOUR;

	public static final String PARAM_RET_URL = 'retURL';
	public static final String PARAM_ID = 'id';
	public static final String PARAM_ROUTE = 'route';
	public static final String PARAM_WHO = 'who_id';
	public static final String PARAM_WHAT = 'what_id';

	public static final String XM_GEN_ERROR = 'Unable to generate {0}: {1}';
	public static final String XM_ASSERT_VALUE = 'Value mismatch on {0}, for {1}. Expected {2}, got {3}. {4}';
	public static final String XM_INVALID_METHOD_PARAMS = 'Invalid parameters for method: {0}. {1}';
	public static final String XM_NO_CLIENT = '[GEN] Client record not found.';
	public static final String CANCELLATION_CODE = 'SS_CANCELLATION_FEES';

	public static final Integer MAX_APEX_BATCH = 2000;
	public static final Integer MEDIUM_APEX_BATCH = 500;
	public static final Integer MAX_DML_BATCH = 10000;

	public static final Date SYS_BOOTSTRAP_DATE = Date.newInstance(2014, 7, 1);
}