page 50116 "Options Card"
{
    PageType = Card;
    SourceTable = "Option";
    AboutTitle = 'Option';
    CardPageId = "Options Card";
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

                    begin
                        if not initialized then
                            initialize();
                        // CurrPage.OptionDesignatorsList.Page.initialize();
                        if not tableSet then begin
                            CurrPage.OptionDesignatorsList.Page.setOptionRec(rec);
                            CurrPage.OptionDesignatorsList.Page.createCustomTable();
                            CurrPage.OptionDesignatorsList.Page.setTableSet();
                            tableSet := true;
                        end;
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
                field(Caption; Rec.Caption)
                {
                    ApplicationArea = All;
                    Enabled = (rec.name <> '');
                }
                field(Required; Rec.Required)
                {
                    ApplicationArea = All;
                    Enabled = (rec.name <> '');
                }
                field("Price Change"; Rec."Price Change")
                {
                    ApplicationArea = All;
                    Enabled = (rec.name <> '');
                }


            }
            grid(Designators)
            {


                group("designatorGroup")
                {



                    field("Prefix Designator"; Rec."Prefix Designator")
                    {
                        ApplicationArea = All;
                        Enabled = (rec.name <> '');

                        trigger OnValidate()
                        var

                        begin
                            if not initialized then
                                initialize();

                            addToList();




                        end;
                    }
                    field("Prefix Order"; Rec."Prefix Order")
                    {
                        ApplicationArea = All;
                        Enabled = (rec.name <> '');
                        trigger OnValidate()
                        var

                        begin
                            if not initialized then
                                initialize();
                            addToList();




                        end;
                    }
                    field("Assembly Change for Prefix"; rec.AssemblyId)
                    {
                        ApplicationArea = all;
                        TableRelation = "Option Assembly Line".ID;
                        Lookup = false;
                        DrillDown = true;
                        DrillDownPageId = "Option Assembly List";

                        trigger OnDrillDown()
                        begin
                            rec.AssemblyId := CurrPage.OptionDesignatorsList.Page.runAssemblyList(true, rec);
                            rec.Modify();
                        end;



                    }
                    field("Suffix Order"; Rec."Suffix Order")
                    {
                        ApplicationArea = All;
                        Enabled = (rec.name <> '');
                        trigger OnValidate()
                        var

                        begin
                            if not initialized then
                                initialize();

                            // CurrPage.OptionDesignatorsList.Page.updatePrefix(rec);

                            CurrPage.OptionDesignatorsList.Page.setOptionRec(rec);
                            CurrPage.OptionDesignatorsList.Page.updateOrder();
                        end;
                    }

                }
            }
            part(OptionDesignatorsList; "Option Suffixs")
            {
                ApplicationArea = All;
                Enabled = (rec.name <> '');
                SubPageLink = OptionID = field("Id");
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
    begin
        if NOT initialized then
            initialize();
        // UpdateSamplePartNumber();
        // CurrPage.Update();
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin

    end;

    procedure initialize()
    var
        oRec: Record Option;
    begin
        // CurrPage.OptionDesignatorsList.Page.updateOptionRec(Rec);

        if rec.Id = 0 then begin
            if OptionMgt.CreateOption(rec) then begin
                CurrPage.Update(false);
            end;
        end;
        CurrPage.OptionDesignatorsList.Page.setOptionRec(rec);

        CurrPage.Update();
        initialized := true;
    end;

    procedure CountOptions(): Integer
    var
        OptionRec: Record "Option";
    begin
        if OptionRec.FindSet then begin
            exit(OptionRec.Count);
        end else begin
            exit(0);
        end;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        addToList();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        oRec: Record Option;
    begin

        if rec.Id = 0 then begin
            if oRec.FindLast() then begin
                rec.Id := oRec.Id + 1;
            end else begin
                rec.Id := 1000;
            end;
        end;
        if oRec.Get(0) then
            oRec.Delete
    end;

    trigger OnClosePage()
    var

        sl: Record SPList;
    begin
        if rec.Name <> '' then begin
            rec.Validate(Name);
            rec.Modify();
            addToList();
            if sl.Get(Format(rec.id) + rec."Prefix Designator") then begin
                sl.active := false;
                sl.Modify();
            end;
        end else begin

            if rec.Delete(true) then begin


            end;
        end;
        CurrPage.Update(false);
    end;

    procedure addToList()
    var
        SPRec, sp : Record SPList;
        sRec: Record "Option Suffix";
        LastID: Integer;
    begin
        if SPRec.Get(Format(rec.id) + rec."Prefix Designator") then begin
            SPRec.Designator := rec."Prefix Designator";
            SPRec.Order := rec."Prefix Order";
            SPRec.active := true;
            SPRec.prefix := true;
            SPRec.Modify();
        end else begin
            SPRec.Init();
            SPRec.ID := format(rec.Id) + rec."Prefix Designator";
            SPRec.Designator := rec."Prefix Designator";
            SPRec.Order := rec."Prefix Order";
            SPRec.active := true;
            SPRec.prefix := true;
            SPRec.OptionID := rec.Id;
            if not SPRec.Insert() then begin

            end;
        end;

        sRec.SetRange(OptionID, rec.Id);
        if sRec.FindSet then begin
            repeat
                if SPRec.Get(Format(sRec.OptionID) + sRec."Suffix Designator") then begin
                    SPRec.Designator := sRec."Suffix Designator";
                    SPRec.Order := rec."Suffix Order";
                    SPRec.prefix := false;
                    SPRec.Modify();
                end else begin
                    SPRec.Init();
                    SPRec.ID := format(rec.Id) + sRec."Suffix Designator";
                    SPRec.Designator := sRec."Suffix Designator";
                    SPRec.Order := rec."Suffix Order";
                    SPRec.OptionID := rec.Id;
                    SPRec.prefix := false;
                    if not SPRec.Insert() then begin

                    end;
                end;
            until sRec.Next() = 0;
        end;
        sRec.Reset();
        CurrPage.OptionDesignatorsList.Page.updateControl();
    end;



    var
        tableSet: Boolean;
        OptionMgt: Codeunit OptionCRUD;
        initialized: Boolean;
        showConn: Boolean;

}