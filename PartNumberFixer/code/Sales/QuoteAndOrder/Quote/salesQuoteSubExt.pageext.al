pageextension 50103 SalesQuoteSubformExt extends "Sales Quote Subform"
{
    layout
    {
        addbefore("Type")
        {
            field(lineNo; rec."Line No.")
            {
                ApplicationArea = all;
            }
            field(PartNo; Rec.PartNo)
            {
                ApplicationArea = ALL;
                Caption = 'Part Number';
                AssistEdit = false;

                DrillDown = true;
                Lookup = true;
                DrillDownPageId = OptionLineList;
                LookupPageId = "Intermediary Part List";
                TableRelation = "Intermediary Part Table";
                trigger OnValidate()
                var
                    UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
                    sHead: Record "Sales Order Entity Buffer";
                    ioRec: Record "Item Option Line";
                    slRec, badRec : Record "Sales Line";
                begin
                    Message('%1', rec.PartNo);
                    UpdateSalesLineFields.UpdateFieldsOnPartNoChange(Rec);
                    if sHead.Get(rec."Document No.") then begin
                        if (sHead."Bill-to Customer No." <> '') then begin
                            if (rec."Bill-to Customer No." = '') then begin
                                rec.Validate("Bill-to Customer No.", sHead."Bill-to Customer No.");
                                hRec := sHead;
                            end;
                        end;
                    end;

                    if rec."Line No." <> 0 then begin
                        rec.Modify(true);
                    end else begin
                        slRec.Reset();
                        slRec.SetRange("Document No.", rec."Document No.");
                        if slRec.FindLast() then begin
                            Message('r: %1 sl: %2', rec."Line No.", slRec."Line No.");
                            rec."Line No." := slRec."Line No." + 10000;
                        end else begin
                            rec."Line No." := 10000;
                        end;
                        ioRec.Reset();
                        ioRec.SetFilter("ItemNo.", rec."No.");
                        if rec.Insert(ioRec.FindFirst()) then begin
                            ioRec.Reset();
                            ioRec.SetFilter("ItemNo.", rec."No.");
                            if ioRec.FindFirst() then begin
                                openPickPage();
                            end;
                        end;
                    end;


                    CurrPage.Update(false);
                end;

                // UpdateSalesLineFields.UpdateFields(Rec, xRec, ((xRec."No." = '') and (xRec.PartNo = '')));

                trigger OnDrillDown()
                var
                    UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
                    sHead: Record "Sales Order Entity Buffer";
                    ioRec: Record "Item Option Line";
                begin
                    ioRec.Reset();
                    ioRec.SetFilter("ItemNo.", rec."No.");
                    if ioRec.FindFirst() then begin
                        openPickPage();
                    end;

                end;

                trigger OnAssistEdit()
                var
                    ItemRec: Record Item;
                    IntermediaryPartRec: Record "Intermediary Part Table";
                    UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
                begin

                    CurrPage.Update;// Force a page update
                    exit;
                end;


            }

        }
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
            begin
                UpdateSalesLineFields.UpdateFieldsOnNoChange(Rec, xRec);
            end;
        }
        modify("Description")
        {
            trigger OnAfterValidate()
            var
                UpdateSalesLineFields: Codeunit UpdateSalesLineFields;
            begin
                UpdateSalesLineFields.UpdateFieldsOnDescChange(Rec, xRec);
            end;
        }
        modify("Qty. to Assemble to Order")
        {
            trigger OnAfterValidate()

            begin
                updateAssemblyInfo();
            end;
        }


    }
    actions
    {
        addfirst(Page)
        {
            action("Trigger the thing")
            {
                trigger OnAction()
                var
                    dRec: Record "Assembly Line";
                begin
                    dRec.SetFilter("Document No.", rec."Document No.");
                    dRec.SetRange("Line No.", rec."Line No.");
                    if dRec.findSet() then begin
                        Message('%1', dRec);
                    end;
                end;
            }
        }
    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        ioRec: Record "Item Option Line";
    begin
        if ((rec."Line No." / 5000) mod 2) = 1 then
            exit(false);
        Message('%1', rec."Line No.");
        ioRec.Reset();
        ioRec.SetFilter("ItemNo.", rec."No.");
        if ioRec.FindFirst() then begin
            openPickPage();
        end;
    end;

    trigger OnAfterGetRecord()
    var
        ioRec: Record "Item Option Line";
        olRec: Record "OptionLine";
        iRec: Record item;
        p, s : Text[50];

    begin
        p := '';
        s := '';

        ioRec.Reset();
        ioRec.SetFilter("ItemNo.", rec."No.");
        if ioRec.FindSet() then begin
            olRec.Reset();
            olRec.SetFilter(docID, rec."Document No.");
            olRec.SetRange(line, rec."Line No.");
            olRec.SetCurrentKey(sufOrder, preOrder);
            olRec.SetAscending(sufOrder, true);
            olRec.SetAscending(preOrder, true);
            if olRec.FindSet() then begin
                s += olRec.sufSelection;
                p += olRec.preSelection;
            end;

        end;
        if iRec.get(rec."No.") then begin
            rec.PartNo := p + iRec.PartNo + s;
        end;
        CurrPage.Update(false);
    end;

    // trigger OnModifyRecord(): Boolean
    // var
    //     ioRec: Record "Item Option Line";

    // begin
    //     ioRec.Reset();
    //     ioRec.SetFilter("ItemNo.", rec."No.");
    //     if ioRec.FindFirst() then begin
    //         openPickPage();
    //     end;
    // end;


    procedure openPickPage(): Text[100]
    var
        lRec, ol, fpg : Record OptionLine;
        sRec: Record SPList;
        iRec: Record Item;
        ioRec: Record "Item Option Line";
        slRec: Record "Sales Line";
        opPage: Page OptionLineList;
        pn: Text[200];
    begin
        // Message('lN: %1', rec."Line No.");
        ioRec.Reset();
        ioRec.SetFilter("ItemNo.", rec."No.");
        ol.Reset();
        ol.SetFilter(docID, rec."Document No.");
        // ol.SetRange(iID, rec."No.");
        ol.SetRange(line, rec."Line No.");
        if not ol.FindSet() then begin
            if ioRec.FindSet() then begin
                repeat
                    lRec.Reset();
                    lRec.Init();
                    lRec.docID := rec."Document No.";
                    lRec.Id := lRec.getNewID();
                    lRec.iID := ioRec."ItemNo.";
                    lRec.oID := ioRec.OptionID;
                    lRec.pre := ioRec.pre;
                    lRec.oName := ioRec.OptionName;
                    lRec.pn := rec.PartNo;
                    lRec.line := rec."Line No.";
                    lRec.Insert();
                // Message('lrLN: %1', lRec.line);
                until ioRec.Next() = 0;
            end;
        end;
        lRec.Reset();
        // lRec.SetRange(iID, rec."No.");

        opPage.SetTableView(ol);
        // Message('Filters: %1', ol.GetFilters);
        opPage.setI(rec);
        Commit();
        if opPage.RunModal() = Action::OK then begin



            CurrPage.Update(false);
            // Clear(opPage);
        end;

    end;

    procedure updateAssemblyInfo()
    var
        aRec: Record "Option Assembly Line";
        lRec: Record OptionLine;
        dRec: Record "Assembly Line";
        iRec: Record Item;
        bStr: Text[1];
    begin
        bStr := '';
        aRec.Reset();
        lRec.Reset();
        lRec.SetFilter(docID, rec."Document No.");
        lRec.SetRange(line, rec."Line No.");
        if lRec.FindSet() then begin
            repeat
                if lRec.preSelection <> '' then begin
                    aRec.Reset();
                    aRec.SetRange("Option ID", lRec.oID);
                    aRec.SetFilter(Designator, lRec.preSelection);
                    if aRec.FindSet() then begin
                        repeat
                            Message('activated for %1', aRec.Designator);
                            dRec.Reset();
                            dRec.init();
                            dRec.Type := dRec.Type::Item;
                            dRec."Document Type" := rec."Document Type"::Quote;
                            dRec."Document No." := rec."Document No.";
                            dRec."Line No." := rec."Line No.";
                            dRec."No." := aRec.No;
                            dRec.Description := aRec.Description;
                            dRec."Unit of Measure Code" := aRec.UOM;
                            dRec."Quantity per" := aRec.Qty;
                            dRec."Quantity (Base)" := aRec.Qty * rec.Quantity;
                            if iRec.get(aRec.No) then begin
                                dRec."Cost Amount" := iRec."Unit Cost" * dRec.Quantity;
                            end;
                            if dRec.Insert() then
                                Message('%1', dRec);
                        until aRec.Next() = 0;
                    end;
                end;
                if lRec.sufSelection <> '' then begin
                    aRec.Reset();
                    aRec.SetRange("Option ID", lRec.oID);
                    aRec.SetFilter(Designator, lRec.sufSelection);
                    if aRec.FindSet() then begin
                        repeat
                            Message('activated for %1', aRec.Designator);
                            dRec.Reset();
                            dRec.init();
                            dRec.Type := dRec.Type::Item;
                            dRec."Document Type" := rec."Document Type"::Quote;
                            dRec."Document No." := rec."Document No.";
                            dRec."Line No." := rec."Line No.";
                            dRec."No." := aRec.No;
                            dRec.Description := aRec.Description;
                            dRec."Unit of Measure Code" := aRec.UOM;
                            dRec."Quantity per" := aRec.Qty;
                            dRec."Quantity (Base)" := aRec.Qty * rec.Quantity;
                            if iRec.get(aRec.No) then begin
                                dRec."Cost Amount" := iRec."Unit Cost" * dRec.Quantity;
                            end;
                            if dRec.Insert() then
                                Message('%1', dRec);
                        until aRec.Next() = 0;
                    end;
                end;
                Message('%1', dRec);
            until lRec.Next() = 0;
        end;

    end;



    procedure getPNwOpts()
    var
        lRec: Record OptionLine;
    begin
        // lRec.SetFilter(docID, rec."Document No.");
        // lRec.SetRange(line, rec."Line No.");
        // lRec.SetRange(iID, rec."No.");
        // if lRec.FindFirst() then begin
        //     rec.PartNo := lRec.pn;
        //     Message('%1', rec.PartNo);
        // end;
    end;

    var
        opPage: Page OptionLineList;
        oCU: Codeunit "OP Page Manager";
        hRec: Record "Sales Order Entity Buffer";
        p: Page "Assemble-to-Order Lines";

}