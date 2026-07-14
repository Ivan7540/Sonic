/**
 * Created by simonas on 2021-08-18.
 */

public class CaseHandler extends TH_BaseObject
{
	private ICaseValidator validator = new CaseValidator();

	public override void bulkBefore()
	{
		if (Trigger.isUpdate)
		{
			this.validator = new CaseUpdateValidator();
		}
		this.validator.initialize((List<Case>)Trigger.new);
	}

	public override void beforeUpdate(SObject oldCase, SObject newCase)
	{
		this.validator.validate((Case) oldCase, (Case) newCase);
	}

	private class CaseValidator implements ICaseValidator
	{
		public void initialize(List<Case> updatedCases)
		{
		}

		public void validate(Case oldCase, Case newCase)
		{
		}
	}
}