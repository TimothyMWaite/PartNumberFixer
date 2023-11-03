page 50118 "Option Suffixs"
{
    PageType = ListPart;
    SourceTable = "Option Suffix";
    ApplicationArea = All;
    ModifyAllowed = true;
    MultipleNewLines = false;

    layout
    {
        area(content)
        {
            repeater("Suffix Designators")
            {
                field("Suffix Designator"; Rec."Suffix Designator")
                {
                    ApplicationArea = All;
                    Caption = 'Change at end of PN';
                    trigger OnValidate()
                    var

                    begin


                    end;

                }
                field(AssemblyChange; Rec.AssemblyChange)
                {
                    ApplicationArea = All;
                    Enabled = (Rec."Suffix Designator" <> '');
                }
                field("Active"; Rec.show)
                {
                    ApplicationArea = All;
                    Enabled = (Rec."Suffix Designator" <> '');
                    trigger OnValidate()
                    begin
                        if rec.show then begin
                            AddToTempTable(rec);

                        end else begin

                            RemoveFromTempTable(rec);
                        end;

                    end;
                }
            }
            group("Example Part Number")
            {
                usercontrol("CombinedControl"; CombinedControl)
                {
                    trigger openAddOptions()
                    var
                        MyModalPage: Page "SPList";
                    begin
                        MyModalPage.SetTableView(TempRec);
                        if MyModalPage.RunModal = Action::OK then begin

                            CurrPage.CombinedControl.updateValues(MyModalPage.getPreText(optionRec.Id), MyModalPage.getSufText(optionRec.Id));

                            // Pass these values to your user control
                        end;
                    end;

                }
            }
        }
    }
    actions
    {
        area(Processing)
        {


            action("Create Table")
            {
                trigger OnAction()
                var
                    OldOption, NewOption : Record "Option";
                    OptionCount: Integer;
                begin
                    // Save the current option
                    CurrPage.CombinedControl.addControl();
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        if not tableSet then begin
            createCustomTable();
            tableSet := true;
        end;
        rec.show := false;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        // Initialize the new record with default values
        Rec.AssemblyChange := '';
        Rec.show := false;
        Rec.OptionID := optionRec.Id;
        // Add the new suffix to the custom control with default values
        AddNewSuffix(Rec."Suffix Designator", Rec.AssemblyChange, Rec.show);
    end;

    procedure createCustomTable()
    var
        oRec: Record Option;
        sRec: Record "Option Suffix";
    begin
        CurrPage.CombinedControl.addControl();

    end;

    procedure AddToTempTable(CurrentRec: Record "Option Suffix")
    begin
        // Add a new record to the temporary table based on the current suffix record
        TempRec.Init();
        TempRec.Designator := CurrentRec."Suffix Designator";
        TempRec.Active := CurrentRec.show;  // Assuming 'show' is equivalent to 'Active'
        TempRec.OptionID := CurrentRec.OptionID;
        TempRec.Insert();
    end;

    procedure RemoveFromTempTable(CurrentRec: Record "Option Suffix")
    begin
        // Remove the corresponding record from the temporary table
        TempRec.SetRange(OptionID, CurrentRec.OptionID);
        TempRec.SetRange(Designator, CurrentRec."Suffix Designator");

        if TempRec.FindFirst() then
            TempRec.Delete();
    end;

    procedure updatePrefix(o: Record Option; old: Record Option)
    begin
        // CurrPage.CombinedControl.UpdateData('prefix', old."Prefix Designator", o."Prefix Designator", o."Prefix Order", true, true);
    end;

    procedure updateSuffix()
    begin
        // CurrPage.CombinedControl.UpdateData('suffix', xrec."Suffix Designator", rec."Suffix Designator", rec."Suffix Order", true, true);
    end;

    procedure updateSamplePartNumber()
    var
        PrefixString, SuffixString : Text[500];
    begin
        // Sort the temporary table by your sorting field, e.g., "SortOrder" if you have one
        TempRec.SetCurrentKey("Order");
        TempRec.Ascending(true);
        Message('in USPN %1 ', TempRec);

        // Loop through sorted records and build the prefix and suffix strings
        if TempRec.FindSet() then begin
            repeat
                if TempRec.Prefix then
                    PrefixString := PrefixString + TempRec.Designator
                else
                    SuffixString := SuffixString + TempRec.Designator;
            until TempRec.Next() = 0;
        end;
        CurrPage.CombinedControl.UpdateValues(PrefixString, SuffixString);
    end;

    procedure setOptionRec(o: Record Option)
    var
    begin
        optionRec := o;
    end;

    procedure updatePrefix(o: Record Option)
    begin

    end;

    procedure updateSuffix(o: Record Option)
    begin

    end;

    procedure AddNewSuffix(newDesignator: Text; newAssemblyChange: Text; newActive: Boolean)
    var
        sRec: Record "Option Suffix";
    begin
        sRec.Init();
        sRec."Suffix Designator" := newDesignator;
        sRec.AssemblyChange := newAssemblyChange;
        sRec.show := newActive;
        // if sRec.Insert() then
        //     CurrPage.CombinedControl.AddData('suffix', newDesignator, sRec."Suffix Order", newActive, true);
    end;

    procedure DeleteSuffix(designatorToDelete: Text)
    var
        sRec: Record "Option Suffix";
    begin
        // if sRec.Get(designatorToDelete) then
        //     if sRec.Delete() then
        //         CurrPage.CombinedControl.DeleteData('suffix', designatorToDelete);
    end;

    procedure EditSuffix(oldDesignator: Text; newDesignator: Text; newAssemblyChange: Text; newActive: Boolean)
    var
        sRec: Record "Option Suffix";
    begin
        if sRec.Get(oldDesignator) then begin
            sRec."Suffix Designator" := newDesignator;
            sRec.AssemblyChange := newAssemblyChange;
            sRec.show := newActive;
            // if sRec.Modify() then
            //     CurrPage.CombinedControl.UpdateData('suffix', oldDesignator, newDesignator, sRec."Suffix Order", newActive, true);
        end;
    end;

    procedure SetActiveStatus(designator: Text; activeStatus: Boolean)
    var
        sRec: Record "Option Suffix";
    begin
        if sRec.Get(designator) then begin
            sRec.show := activeStatus;
            // if sRec.Modify() then
            //     CurrPage.CombinedControl.UpdateData('suffix', designator, designator, sRec."Suffix Order", activeStatus, true);
        end;
    end;


    var
        optionRec: Record Option;
        TempRec: Record SPList temporary;
        tableSet: Boolean;

}