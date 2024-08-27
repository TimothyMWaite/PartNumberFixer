pageextension 50103 SalesQuoteSubformExt extends "Sales Quote Subform"
{
    layout
    {
        addbefore("Type")
        {
            field(LineNumber; Rec."Line No.")
            {
                ApplicationArea = All;
            }

            field(PartNumber; Rec.PartNumber)
            {
                ApplicationArea = All;
                Caption = 'Part Number';
                AssistEdit = false;
                ToolTip = 'This is a custom field and can be edited as needed. Any changes will not affect the default part number and will only be saved in this document. If you need to change the default part number, go to the item page and do it there.';
                DrillDown = true;
                Lookup = true;
                DrillDownPageId = OptionLineList;
                LookupPageId = "Intermediary Part List";
                TableRelation = "Intermediary Part Table";

                trigger OnAfterLookup(Selected: RecordRef)
                var
                    SalesLineRecord: Record "Sales Line";
                begin
                    // Update the line number after lookup
                    UpdateLineNumber();
                    exit;
                end;

                trigger OnValidate()
                var
                    SalesLineUpdater: Codeunit UpdateSalesLineFields;
                    PartNumberManager: Codeunit PartNoManager;
                    SalesQuoteBuffer: Record "Sales Quote Entity Buffer";
                    SalesLineRecord, BadSalesLineRecord : Record "Sales Line";
                    OptionLineRecord: Record "OptionLine";
                    ItemRecord: Record Item;
                    BasePartNumber: Text[100];
                    PickInstructionReport: Report "Pick Instruction";
                begin
                    // Delete the record if PartNumber is empty
                    if Rec.PartNumber = '' then begin
                        Rec.Delete();
                        exit;
                    end;

                    // Set the "Bill-to Customer No." if it's not set yet
                    if SalesQuoteBuffer.Get(Rec."Document No.") then begin
                        if SalesQuoteBuffer."Bill-to Customer No." <> '' then begin
                            if Rec."Bill-to Customer No." = '' then begin
                                Rec.Validate("Bill-to Customer No.", SalesQuoteBuffer."Bill-to Customer No.");
                            end;
                        end;
                    end;

                    // Set a default shipment number if it's not set
                    if Rec.ShipmentNumber = 0 then begin
                        Rec.ShipmentNumber := 1;
                    end;

                    // Update item fields based on the selected PartNumber
                    ItemRecord.Reset();
                    ItemRecord.SetFilter(PartNumber, Rec.PartNumber);
                    if ItemRecord.FindFirst() then begin
                        Rec."No." := ItemRecord."No.";
                        Rec.Description := ItemRecord.Description;
                        Rec."Unit of Measure" := ItemRecord."Unit of Measure Id";
                        Rec."Unit Price" := ItemRecord."Unit Price";
                        Rec.Validate("No.", ItemRecord."No.");

                        // Insert or modify the record if a new item has been selected
                        if (ItemRecord.PartNumber <> BasePartNumber) OR (Rec."Line No." <> OldLineNumber) then begin
                            Rec.PartNumber := ItemRecord.PartNumber;
                            if not Rec.Insert(true) then begin
                                Rec.Modify(false);
                            end;
                            if ItemRecord.opts then begin
                                CurrentPartNumber := OpenPickPage();
                            end;
                        end;
                    end;

                    // Update the page to reflect changes
                    CurrPage.Update(false);
                    BasePartNumber := Rec.GetItem().PartNumber;
                    OldLineNumber := Rec."Line No.";
                end;

                trigger OnDrillDown()
                begin
                    // If the item has options, open the pick page to select an option
                    if Rec.GetItem().opts then begin
                        Rec.PartNumber := OpenPickPage();
                        CurrentPartNumber := Rec.PartNumber;
                        CurrPage.Update(false);
                    end;
                end;

                trigger OnAssistEdit()
                begin
                    // Force a page update during AssistEdit
                    CurrPage.Update;
                    exit;
                end;
            }

            field(LeadTime; Rec.LeadTime)
            {
                ApplicationArea = All;
                Caption = 'Lead Time';
                Visible = Rec."Document Type" = Rec."Document Type"::Quote;

                trigger OnValidate()
                var
                    RegEx: Codeunit Regex;
                begin
                    // Update ship date based on lead time if the document type is Order
                    if Rec."Document Type" = Rec."Document Type"::Order then begin
                        if Rec.LeadTime <> '' then begin
                            UpdateShipDateByLeadTime();
                        end;
                    end;
                end;
            }

            field(ShipmentNumber; Rec.ShipmentNumber)
            {
                ApplicationArea = All;
                Caption = 'Shipment Number';
                Visible = Rec."Document Type" = Rec."Document Type"::Order;
                Enabled = Rec.PartNumber <> '';

                trigger OnValidate()
                var
                    SplitTravelerHandler: Record "SplitTravelerHandler";
                begin
                    // Set default shipment number and validate it
                    if Rec.ShipmentNumber = 0 then begin
                        Rec.ShipmentNumber := 1;
                    end;
                    if Rec.GetSalesHeader().TotalNumberOfShipments < Rec.ShipmentNumber then begin
                        Rec.Validate(Rec.ShipmentNumber, Rec.GetSalesHeader().TotalNumberOfShipments);
                    end;
                    SplitTravelerHandler.CreateRecords(Rec); // Create records based on the shipment number
                end;
            }
        }

        modify("No.")
        {
            trigger OnAfterValidate()
            var
                SalesLineUpdater: Codeunit UpdateSalesLineFields;
            begin
                // Update fields after validating the "No." field
                SalesLineUpdater.UpdateFieldsOnNoChange(Rec, xRec);
            end;
        }

        modify("Description")
        {
            trigger OnAfterValidate()
            var
                SalesLineUpdater: Codeunit UpdateSalesLineFields;
            begin
                // Update fields after validating the "Description" field
                SalesLineUpdater.UpdateFieldsOnDescChange(Rec, xRec);
            end;
        }

        modify("Quantity")
        {
            trigger OnAfterValidate()
            begin
                // Set the "Qty. to Assemble to Order" field if the item has a BOM
                if Rec.GetItem().HasBOM() then begin
                    Rec."Qty. to Assemble to Order" := Rec.Quantity;
                    Rec.Modify(false);
                    Rec.Validate("Qty. to Assemble to Order");
                end;
            end;
        }

        modify("Qty. to Assemble to Order")
        {
            trigger OnBeforeValidate()
            begin
                // Placeholder for logic before validating "Qty. to Assemble to Order"
            end;

            trigger OnAfterValidate()
            begin
                // Update assembly information after validating "Qty. to Assemble to Order"
                UpdateAssemblyInfo();
            end;
        }
    }

    trigger OnClosePage()
    var
        SalesLineRecord: Record "Sales Line";
    begin
        // Delete lines with empty PartNumber and of type "Item"
        SalesLineRecord.SetFilter("Document No.", Rec."Document No.");
        SalesLineRecord.SetRange("Line No.", 10000);
        if SalesLineRecord.FindFirst() then begin
            if (SalesLineRecord.PartNumber = '') AND (SalesLineRecord.Type = "Sales Line Type"::Item) then begin
                SalesLineRecord.Delete();
            end;
        end;
        if (Rec.PartNumber = '') AND (SalesLineRecord.Type = "Sales Line Type"::Item) AND (Rec."Line No." <> 0) then begin
            Rec.Delete();
        end;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        // Prevent insertion if the line number is odd (and not divisible by 5000)
        if ((Rec."Line No." / 5000) mod 2) = 1 then begin
            exit(false);
        end;
        exit(true);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        ItemRecord: Record Item;
        OptionLineRecord: Record "OptionLine";
    begin
        // Delete option lines related to the current item if it has options
        BasePartNumber := '';
        if Rec."No." <> '' then begin
            ItemRecord := Rec.GetItem();
            if ItemRecord.opts then begin
                if ItemRecord.PartNumber <> Rec.PartNumber then begin
                    OptionLineRecord.Reset();
                    OptionLineRecord.SetFilter(DocumentID, Rec."Document No.");
                    OptionLineRecord.SetRange(LineNumber, Rec."Line No.");
                    if OptionLineRecord.FindSet() then begin
                        repeat
                            OptionLineRecord.Delete();
                        until OptionLineRecord.Next() = 0;
                    end;
                end;
            end;
        end;
        exit(true);
    end;

    trigger OnAfterGetRecord()
    begin
        // Placeholder for operations after getting the record
    end;

    local procedure CreateDisplayText(FieldName: Text; Value1: Text; Value2: Text): Text
    begin
        // Create display text combining field name and values
        exit(StrSubstNo('%1 -> Record1: %2, Record2: %3', FieldName, Value1, Value2));
    end;

    local procedure NextNonWeekend(CalculationDate: Date): Date
    var
        DayOfWeek: Integer;
    begin
        // Calculate the next non-weekend date
        DayOfWeek := Date2DWY(CalculationDate, 1);
        if DayOfWeek = 6 then begin
            exit(CalcDate('+2D', CalculationDate));
        end else if DayOfWeek = 7 then begin
            exit(CalcDate('+1D', CalculationDate));
        end else begin
            exit(CalculationDate);
        end;
    end;

    procedure OpenPickPage(): Text[100]
    var
        OptionLineRecord, OptionLineRecordCopy, TempOptionLine : Record OptionLine;
        ItemRecord: Record Item;
        SalesLineRecord: Record "Sales Line";
        PickPage: Page SalesLineItem;
        AssemblyManager: Codeunit AssemblyManagement;
        PartNumber: Text[200];
    begin
        // Open a modal page to pick an option and return the selected part number
        Commit();
        PickPage.SetRecord(Rec);
        PickPage.RunModal();
        exit(PickPage.GetPN());
    end;

    procedure UpdateAssemblyInfo()
    var
        OptionAssemblyLineRecord: Record "Option Assembly Line";
        AssemblyHeaderRecord, AssemblyHeaderCopy : Record "Assembly Header";
        OptionLineRecord: Record OptionLine;
        SalesHeaderRecord: Record "Sales Header";
        AssemblyLineRecord: Record "Assembly Line";
        IsDeleted: Boolean;
        ItemRecord: Record Item;
        AssembleToOrderLinkRecord: Record "Assemble-to-Order Link";
        AssemblyManager: Codeunit AssemblyManagement;
    begin
        // Update assembly header and lines based on the current sales line data
        OptionAssemblyLineRecord.Reset();
        OptionLineRecord.Reset();
        AssemblyHeaderRecord.Reset();

        AssembleToOrderLinkRecord.SetFilter("Document No.", Rec."Document No.");
        AssembleToOrderLinkRecord.SetRange("Document Line No.", Rec."Line No.");
        if AssembleToOrderLinkRecord.FindFirst() then begin
            if AssemblyHeaderRecord.Get(AssembleToOrderLinkRecord."Assembly Document Type", AssembleToOrderLinkRecord."Assembly Document No.") then begin
                AssemblyHeaderCopy := AssemblyHeaderRecord;
            end else begin
                AssemblyHeaderCopy.Init();
                AssemblyHeaderCopy := AssemblyManager.SetAssemblyHeaderValues(AssemblyHeaderCopy, Rec);
                AssembleToOrderLinkRecord.InsertAsmHeader(AssemblyHeaderCopy, Rec."Document Type", AssemblyHeaderCopy."No.");
            end;
        end else begin
            AssembleToOrderLinkRecord.Init();
            AssemblyHeaderCopy.Init();
            AssemblyHeaderCopy := AssemblyManager.SetAssemblyHeaderValues(AssemblyHeaderCopy, Rec);
            AssembleToOrderLinkRecord := AssemblyManager.SetAssembleToOrderValues(AssembleToOrderLinkRecord, Rec, AssemblyHeaderCopy);
            AssembleToOrderLinkRecord.InsertAsmHeader(AssemblyHeaderCopy, Rec."Document Type", AssemblyHeaderCopy."No.");
            AssembleToOrderLinkRecord.Insert(true);
        end;

        OptionLineRecord.SetFilter(DocumentID, Rec."Document No.");
        OptionLineRecord.SetRange(LineNumber, Rec."Line No.");
        if OptionLineRecord.FindSet() then begin
            repeat
                OptionAssemblyLineRecord.Reset();
                OptionAssemblyLineRecord.SetRange(DesID, OptionLineRecord.PreID);
                if OptionAssemblyLineRecord.FindSet() then begin
                    repeat
                        if OptionAssemblyLineRecord.ReplacePart then begin
                            AssemblyManager.DeleteParts(AssemblyHeaderCopy, OptionAssemblyLineRecord, Rec);
                        end;
                    until OptionAssemblyLineRecord.Next() = 0;
                end;
                OptionAssemblyLineRecord.Reset();
                OptionAssemblyLineRecord.SetRange(DesID, OptionLineRecord.SuffixID);
                if OptionAssemblyLineRecord.FindSet() then begin
                    repeat
                        if OptionAssemblyLineRecord.ReplacePart then begin
                            AssemblyManager.DeleteParts(AssemblyHeaderCopy, OptionAssemblyLineRecord, Rec);
                        end;
                    until OptionAssemblyLineRecord.Next() = 0;
                end;
            until OptionLineRecord.Next() = 0;
        end;

        OptionLineRecord.Reset();
        OptionLineRecord.SetFilter(DocumentID, Rec."Document No.");
        OptionLineRecord.SetRange(LineNumber, Rec."Line No.");
        if OptionLineRecord.FindSet() then begin
            repeat
                IsDeleted := false;
                OptionAssemblyLineRecord.Reset();
                OptionAssemblyLineRecord.SetRange(DesID, OptionLineRecord.SuffixID);
                if OptionAssemblyLineRecord.FindSet() then begin
                    repeat
                        AssemblyManager.ConvertToAssemblyLine(AssemblyHeaderCopy, Rec, OptionAssemblyLineRecord);
                    until OptionAssemblyLineRecord.Next() = 0;
                end;
                OptionAssemblyLineRecord.Reset();
                OptionAssemblyLineRecord.SetRange(DesID, OptionLineRecord.PreID);
                if OptionAssemblyLineRecord.FindSet() then begin
                    repeat
                        AssemblyManager.ConvertToAssemblyLine(AssemblyHeaderCopy, Rec, OptionAssemblyLineRecord);
                    until OptionAssemblyLineRecord.Next() = 0;
                end;
            until OptionLineRecord.Next() = 0;
        end;
    end;

    procedure UpdateLineNumber()
    var
        SalesLineRecord: Record "Sales Line";
    begin
        // Update the line number if it's not set yet
        if Rec."Line No." = 0 then begin
            SalesLineRecord.Reset();
            SalesLineRecord.SetRange("Document No.", Rec."Document No.");
            if SalesLineRecord.FindLast() then begin
                Rec."Line No." := SalesLineRecord."Line No." + 10000;
            end else begin
                Rec."Line No." := 10000;
                Rec."Document Type" := Rec.GetSalesHeader()."Document Type";
                Rec."Document No." := Rec.GetSalesHeader()."No.";
                Rec.Insert();
            end;
        end;
    end;

    procedure ConvertLeadTimeToDate(LeadTimeText: Text): Date
    var
        UnitPosition: Integer;
        DateFormula: Text;
    begin
        // Convert lead time text to a date based on days or weeks
        DateFormula := '';
        UnitPosition := StrPos(UpperCase(LeadTimeText), 'D');
        if UnitPosition > 0 then begin
            DateFormula := StrSubstNo('+%1D', GetHighestNumberFromText(LeadTimeText));
        end else begin
            UnitPosition := StrPos(UpperCase(LeadTimeText), 'W');
            if UnitPosition > 0 then begin
                DateFormula := StrSubstNo('+%1W', GetHighestNumberFromText(LeadTimeText));
            end;
        end;

        exit(NextNonWeekend(CalcDate(DateFormula, Variant2Date(CurrentDateTime))));
    end;

    procedure GetHighestNumberFromText(TextInput: Text): Integer
    var
        MaxNumber: Integer;
        CurrentNumber: Integer;
        NumberText: Text;
        Character: Char;
        i: Integer;
    begin
        // Extract the highest number from the text input
        MaxNumber := 0;
        NumberText := '';

        for i := 1 to StrLen(TextInput) do begin
            Character := TextInput[i];

            if Character in ['0' .. '9'] then
                NumberText := NumberText + Character
            else begin
                if NumberText <> '' then begin
                    CurrentNumber := EvaluateNumber(NumberText);
                    if CurrentNumber > MaxNumber then
                        MaxNumber := CurrentNumber;
                    NumberText := '';
                end;
            end;
        end;

        if NumberText <> '' then begin
            CurrentNumber := EvaluateNumber(NumberText);
            if CurrentNumber > MaxNumber then
                MaxNumber := CurrentNumber;
        end;

        exit(MaxNumber);
    end;

    procedure EvaluateNumber(NumberText: Text): Integer
    var
        Number: Integer;
    begin
        // Convert text to integer
        if Evaluate(Number, NumberText) then
            exit(Number)
        else
            Error('Failed to evaluate number: %1', NumberText);
    end;

    procedure UpdateShipDateByLeadTime()
    var
        SalesLineRecord: Record "Sales Line";
    begin
        // Update the shipment date based on lead time
        SalesLineRecord.SetFilter("Document No.", Rec."Document No.");
        if SalesLineRecord.FindSet() then begin
            repeat
                SalesLineRecord."Shipment Date" := ConvertLeadTimeToDate(Rec.LeadTime);
                SalesLineRecord.Modify();
            until SalesLineRecord.Next() = 0;
        end;
    end;

    var
        OptionPage: Page OptionLineList;
        CurrentPartNumber, PreviousPartNumber, BasePartNumber : Text[200];
        OldLineNumber: Integer;

}
