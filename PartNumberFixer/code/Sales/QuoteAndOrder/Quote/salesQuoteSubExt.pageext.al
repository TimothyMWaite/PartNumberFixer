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
            trigger OnBeforeValidate()

            begin

                updateAssemblyInfo();

            end;

            trigger OnAfterValidate()
            var
                dR2: Record "Assembly Line";
            begin
                dR2.SetFilter("Document Type", Format(Rec."Document Type"));
                dR2.SetFilter("Document No.", Format(Rec."Document No."));
                dR2.SetFilter("Line No.", Format(Rec."Line No."));
                if dR2.FindLast() then begin
                    DisplayAssemblyLineRecordFields(d, dR2);
                end;


            end;
        }


    }
    actions
    {
        addafter(Page)
        {
            group(DOIT)
            {
                action(DOTHETHING)
                {
                    Visible = true;
                    ApplicationArea = All;
                    Caption = 'DO THE THING';
                    trigger OnAction()
                    var
                        dRec: Record "Assembly Header";
                    begin
                        // dRec.SetFilter("Document No.", rec."Document No.");
                        // dRec.SetRange("Line No.", rec."Line No.");

                        if dRec.findSet() then begin
                            repeat
                                Message('%1', dRec);

                            until dRec.Next() = 0;
                        end;
                    end;
                }
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

    procedure DisplayAssemblyLineRecordFields(Record1: Record "Assembly Line"; Record2: Record "Assembly Line")
    var
        DisplayText: Text;
    begin
        // Displaying each field for both records
        DisplayText := CreateDisplayText('Type', Format(Record1.Type), Format(Record2.Type));
        Message(DisplayText);

        DisplayText := CreateDisplayText('Document Type', Format(Record1."Document Type"), Format(Record2."Document Type"));
        Message(DisplayText);

        DisplayText := CreateDisplayText('Document No.', Record1."Document No.", Record2."Document No.");
        Message(DisplayText);

        DisplayText := CreateDisplayText('Line No.', Format(Record1."Line No."), Format(Record2."Line No."));
        Message(DisplayText);

        DisplayText := CreateDisplayText('No.', Record1."No.", Record2."No.");
        Message(DisplayText);

        DisplayText := CreateDisplayText('Description', Record1.Description, Record2.Description);
        Message(DisplayText);

        DisplayText := CreateDisplayText('Description 2', Record1."Description 2", Record2."Description 2");
        Message(DisplayText);

        DisplayText := CreateDisplayText('Variant Code', Record1."Variant Code", Record2."Variant Code");
        Message(DisplayText);

        DisplayText := CreateDisplayText('Location Code', Record1."Location Code", Record2."Location Code");
        Message(DisplayText);

        DisplayText := CreateDisplayText('Unit of Measure Code', Record1."Unit of Measure Code", Record2."Unit of Measure Code");
        Message(DisplayText);

        DisplayText := CreateDisplayText('Quantity per', Format(Record1."Quantity per"), Format(Record2."Quantity per"));
        Message(DisplayText);

        DisplayText := CreateDisplayText('Quantity', Format(Record1.Quantity), Format(Record2.Quantity));
        Message(DisplayText);

        DisplayText := CreateDisplayText('Reserved Quantity', Format(Record1."Reserved Quantity"), Format(Record2."Reserved Quantity"));
        Message(DisplayText);

        DisplayText := CreateDisplayText('Consumed Quantity', Format(Record1."Consumed Quantity"), Format(Record2."Consumed Quantity"));
        Message(DisplayText);

        DisplayText := CreateDisplayText('Qty. Picked', Format(Record1."Qty. Picked"), Format(Record2."Qty. Picked"));
        Message(DisplayText);

        DisplayText := CreateDisplayText('Pick Qty.', Format(Record1."Pick Qty."), Format(Record2."Pick Qty."));
        Message(DisplayText);

        DisplayText := CreateDisplayText('Due Date', Format(Record1."Due Date"), Format(Record2."Due Date"));
        Message(DisplayText);

        DisplayText := CreateDisplayText('Lead-Time Offset', Format(Record1."Lead-Time Offset"), Format(Record2."Lead-Time Offset"));
        Message(DisplayText);

        DisplayText := CreateDisplayText('Shortcut Dimension 1 Code', Record1."Shortcut Dimension 1 Code", Record2."Shortcut Dimension 1 Code");
        Message(DisplayText);

        DisplayText := CreateDisplayText('Shortcut Dimension 2 Code', Record1."Shortcut Dimension 2 Code", Record2."Shortcut Dimension 2 Code");
        Message(DisplayText);

        DisplayText := CreateDisplayText('Bin Code', Record1."Bin Code", Record2."Bin Code");
        Message(DisplayText);

        DisplayText := CreateDisplayText('Inventory Posting Group', Record1."Inventory Posting Group", Record2."Inventory Posting Group");
        Message(DisplayText);

        DisplayText := CreateDisplayText('Unit Cost', Format(Record1."Unit Cost"), Format(Record2."Unit Cost"));
        Message(DisplayText);

        DisplayText := CreateDisplayText('Cost Amount', Format(Record1."Cost Amount"), Format(Record2."Cost Amount"));
        Message(DisplayText);

        DisplayText := CreateDisplayText('Qty. per Unit of Measure', Format(Record1."Qty. per Unit of Measure"), Format(Record2."Qty. per Unit of Measure"));
        Message(DisplayText);

        DisplayText := CreateDisplayText('Resource Usage Type', Format(Record1."Resource Usage Type"), Format(Record2."Resource Usage Type"));
        Message(DisplayText);

        DisplayText := CreateDisplayText('Appl.-to Item Entry', Format(Record1."Appl.-to Item Entry"), Format(Record2."Appl.-to Item Entry"));
        Message(DisplayText);

        DisplayText := CreateDisplayText('Appl.-from Item Entry', Format(Record1."Appl.-from Item Entry"), Format(Record2."Appl.-from Item Entry"));
        Message(DisplayText);
    end;

    local procedure CreateDisplayText(FieldName: Text; Value1: Text; Value2: Text): Text
    begin
        exit(StrSubstNo('%1 -> Record1: %2, Record2: %3', FieldName, Value1, Value2));
    end;

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

    procedure addAssLine()
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        AssemblyLineMgt: Codeunit "Assembly Line Management";
    begin
        // Initialize or retrieve your AssemblyHeader record
        // ...
    
        // Insert a new line for the Assembly Header
        AssemblyLineMgt.InsertAsmLine(AssemblyHeader, AssemblyLine, false);

        // Set the details of the new assembly line
        // AssemblyLine.Validate("No.", YourItemNo); // Replace YourItemNo with the actual item number
        // AssemblyLine.Validate(Quantity, YourQuantity); // Replace YourQuantity with the actual quantity
                                                       // Set other fields as needed
                                                       // ...

        // Insert the assembly line record into the database
        AssemblyLine.Insert();
    end;

    procedure updateAssemblyInfo()
    var
        aRec: Record "Option Assembly Line";
        lRec: Record OptionLine;
        dRec, c, dRec2 : Record "Assembly Line";
        iRec: Record Item;
        bStr: Text[1];
        iNo: Code[20];
        p: Page "Assemble-to-Order Lines";
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
                                iNo := iRec."No.";
                            end;
                            if dRec.Insert() then begin
                                d := dRec;


                            end else begin
                                Message('Failed');
                            end;
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
                                iNo := iRec."No.";
                            end;

                            if dRec.Insert() then begin
                                d := dRec;
                            end else begin
                                Message('Failed');
                            end;

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
        d: Record "Assembly Line";
        d2: Record "Assembly Header";

}