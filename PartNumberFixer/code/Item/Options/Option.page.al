page 50116 "Options Card"
{
    PageType = Card;
    SourceTable = "Option";
    AboutTitle = 'Option';
    CardPageId = "Options Card";
    UsageCategory = Documents;
    Caption = 'Option';
    ApplicationArea = All;
    Editable = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Id; rec.Id)
                {
                    ApplicationArea = All;
                    Editable = False;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        o: Record Option;
                        dRec: Record "Option Designators";
                    begin
                        // CurrPage.OptionDesignatorsList.Page.initialize();
                        if not tableSet then begin
                            o := rec;
                            CurrPage.OptionDesignatorsList.Page.setOptionRec(o);
                            CurrPage.OptionDesignatorsList.Page.createCustomTable();
                            CurrPage.OptionDesignatorsList.Page.setTableSet();
                            tableSet := true;
                        end;
                        // rec.Modify();
                        // CurrPage.OptionDesignatorsList.Page.UpdateSamplePartNumber(rec);
                        // if not tableSet then begin
                        //     Message('InOPOT');
                        //     CurrPage.OptionDesignatorsList.Page.createCustomTable();
                        //     tableSet := true;
                        // end;
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Enabled = (rec.name <> '');
                }

                field(Required; Rec.Required)
                {
                    ApplicationArea = All;
                    Enabled = (rec.name <> '');
                }
                field("Item Type"; Rec."Item Type")
                {
                    ApplicationArea = All;
                    Enabled = (rec.name <> '');
                    trigger OnValidate()
                    var
                        d: Record "Option Designators";

                    begin
                        d.Reset();
                        d.SetFilter(OptionID, Format(rec.Id));
                        if d.FindSet() then begin
                            repeat
                                d.itemType := rec."Item Type";
                                d.Modify();
                            until d.Next() = 0;
                        end;
                    end;
                }
            }
            part(OptionDesignatorsList; "Option Designators")
            {
                ApplicationArea = All;
                // Enabled = (rec.name <> '');

                SubPageLink = OptionID = field(Id);
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create New Option")
            {
                trigger OnAction()
                var
                    OldOption, NewOption : Record "Option";
                    OptionCount: Integer;
                begin
                    // Save the current option
                    OptionMgt.UpdateOption(Rec);

                    // Insert the new option to ensure it's saved
                    if OptionMgt.CreateOption(NewOption) then begin
                        PAGE.RUN(PAGE::"Options Card", NewOption);
                        CurrPage.Close();

                    end else begin
                        Message('Creation of new option with ID: %1 failed. Please try again or contact Tim.', NewOption.Id);
                    end;

                    // Open the new card

                    // Close the current card
                end;
            }
            action("Update Option")
            {
                trigger OnAction()
                begin
                    OptionMgt.UpdateOption(Rec);
                    CurrPage.Update();
                end;
            }
            action("Delete Option")
            {
                trigger OnAction()
                begin
                    OptionMgt.DeleteOption(Rec);
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        oRec: Record Option;
        dRec: Record "Option Designators";
    begin

    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin

    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        oRec: Record Option;
        dRec: Record "Option Designators";
    begin
        if oRec.FindLast() then begin
            rec.Id := oRec.Id + 1;
        end else begin
            rec.Id := 1000;
        end;

    end;

    trigger OnClosePage()
    var

        sl: Record "Option Designators";
    begin
        //on close page set all show values to false
        if rec.Name <> '' then begin
            rec.Validate(Name);
            rec.Modify();
        end else begin
            rec.Delete(true);
        end;
        sl.Reset();
        sl.SetFilter(OptionID, Format(rec.Id));
        sl.SetRange(show, true);
        if sl.FindSet() then begin
            repeat
                sl.show := false;
                sl.Modify();
            until sl.Next() = 0;
        end;
        CurrPage.Update(false);
    end;
    var
        tableSet: Boolean;
        OptionMgt: Codeunit OptionCRUD;
        initialized: Boolean;
        showConn: Boolean;
        assemblyEditable: Boolean;

}