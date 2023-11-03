page 50123 OptionList
{
    PageType = List;
    CardPageId = "Options Card";

    ApplicationArea = All;
    SourceTable = Option;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Name; rec.Name)
                {
                    ApplicationArea = All;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Options Card", rec);
                    end;

                }
                field(Description; rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }

    }
    actions
    {
        area(Processing)
        {
            action("Open SPList Page")
            {
                ApplicationArea = All;
                RunObject = page SPList;
                trigger OnAction()
                begin

                end;
            }
        }
    }
}