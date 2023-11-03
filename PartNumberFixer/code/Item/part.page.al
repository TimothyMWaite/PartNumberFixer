page 50104 "Intermediary Part List"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Intermediary Part Table";
    Caption = 'Intermediary Part Table';
    UsageCategory = Lists;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("PartNo"; rec.PartNo)
                {
                    ApplicationArea = All;
                }

                field("Item ID"; rec."Item ID")
                {
                    ApplicationArea = All;
                }
                field("Item Description"; rec."Item Description")
                {
                    ApplicationArea = All;
                }

                // Add other fields if needed
            }
        }
    }
    actions
    {
        area(Creation)
        {
            action(refreshTable)
            {
                ApplicationArea = All;
                Caption = 'Refresh Table';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    MyInstallCodeunit: Codeunit "My Install Codeunit";
                begin
                    Message('Refreshing');
                    MyInstallCodeunit.PopulateIntermediaryTable();
                    CurrPage.UPDATE; // Refresh the page to show the changes
                end;
            }
        }
    }
}