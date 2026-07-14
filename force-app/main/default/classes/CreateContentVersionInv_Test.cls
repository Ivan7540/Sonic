@IsTest
public class CreateContentVersionInv_Test {
    @TestSetup
    static void createData(){
        TestDataFactory.createTestAccounts(1,1,null);
    }
    
    @IsTest
    static void createFileTest(){
        String accountId = [SELECT Id FROM Account limit 1].Id;
        CreateContentVersionInvocable.FlowInput[] inputs = new CreateContentVersionInvocable.FlowInput[]{};
        //inputs.add(createFlowInput('DummyNote', 'SNOTE', 'DummyNoteText', accountId));
        inputs.add(createFlowInput('DummyPNG', 'PNG', 'RandomText', accountId));

        Test.startTest();
        CreateContentVersionInvocable.createFile(inputs);
        Test.stopTest();

        System.assertEquals( 
            1, 
            [SELECT Id FROM ContentDocument WHERE FileType = 'PNG'].size(),
            'Unexpected count of PNG type files.'
        );
        
    }

    static CreateContentVersionInvocable.FlowInput createFlowInput( String title, String fileExtension, String data, String parentId) {

        CreateContentVersionInvocable.FlowInput input = new CreateContentVersionInvocable.FlowInput();
        input.title = title;
        input.fileExtension = fileExtension;
        input.data = data;
        input.documentType = 'Payment';
        if(String.isNotEmpty(parentId)) {
            input.parentId = parentId;
        }

        return input;

    }
}