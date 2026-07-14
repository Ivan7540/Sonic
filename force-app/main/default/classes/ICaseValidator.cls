/**
 * Created by simonas on 2021-08-18.
 */

public interface ICaseValidator
{
	void initialize(List<Case> updatedCases);
	void validate(Case oldCase, Case newCase);
}