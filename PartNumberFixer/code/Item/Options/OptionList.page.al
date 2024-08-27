page 50123 OptionList
{
    PageType = List;
    CardPageId = "Options Card";
    UsageCategory = "Lists";
    Caption = 'Option List';
    AboutTitle = 'Options';
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
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Options Card", rec);
                    end;
                }
            }
        }

    }
    actions
    {
        area(Processing)
        {
            action(New)
            {
                ApplicationArea = All;
                Promoted = true;
                Caption = 'New';
                ToolTip = 'Create a new record.';
                RunPageMode = Create;
                RunObject = Page "Options Card";
                Image = New;
                ShortcutKey = Insert;
            }
            action(Edit)
            {
                ApplicationArea = All;
                Promoted = true;

                Caption = 'Edit';
                ToolTip = 'Edit the selected record.';
                RunPageMode = Edit;
                RunPageOnRec = true;
                RunObject = Page "Options Card";
                Image = Edit;
            }
            action(Delete)
            {
                ApplicationArea = All;
                Promoted = true;
                Caption = 'Delete';
                ToolTip = 'Delete the selected record.';
                trigger OnAction()
                begin
                    if Confirm('Are you sure you want to delete the selected record?') then
                    begin
                        rec.Delete(true);
                    end;
                end;
            }
        }
    }
    procedure getRec(): Record Option
    begin
        exit(rec);
    end;
}