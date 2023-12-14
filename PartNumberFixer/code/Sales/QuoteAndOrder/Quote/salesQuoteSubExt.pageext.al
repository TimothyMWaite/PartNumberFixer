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
                begin

                    UpdateSalesLineFields.UpdateFieldsOnPartNoChange(Rec);
                    if sHead.Get(rec."Document No.") then begin
                        if (sHead."Bill-to Customer No." <> '') then begin
                            if (rec."Bill-to Customer No." = '') then begin
                                rec.Validate("Bill-to Customer No.", sHead."Bill-to Customer No.");
                                hRec := sHead;
                            end;
                        end;
                    end;
                    if rec."Line No." <> 0 then
                        openPickPage();
                    CurrPage.Update();
                end;

                // UpdateSalesLineFields.UpdateFields(Rec, xRec, ((xRec."No." = '') and (xRec.PartNo = '')));

                trigger OnDrillDown()
                begin
                    openPickPage();

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


    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        openPickPage();
    end;

    procedure openPickPage(): Text[100]
    var
        lRec, ol : Record OptionLine;
        sRec: Record SPList;
        iRec: Record Item;
        ioRec: Record "Item Option Line";
        slRec: Record "Sales Line";
        opPage: Page OptionLineList;
        pn: Text[200];
    begin
        Message('lN: %1', rec."Line No.");
        ioRec.Reset();
        ioRec.SetFilter("ItemNo.", rec."No.");
        ol.Reset();
        ol.SetFilter(docID, rec."Document No.");
        ol.SetRange(iID, rec."No.");
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
                    Message('lrLN: %1', lRec.line);
                until ioRec.Next() = 0;
            end;
        end;
        lRec.Reset();
        lRec.SetRange(iID, rec."No.");
        lRec.SetFilter(line, Format(rec."Line No."));
        lRec.SetFilter(docID, rec."Document No.");

        opPage.SetTableView(ol);
        opPage.setI(rec);
        Commit();
        if opPage.RunModal() = Action::OK then begin

            rec.PartNo := opPage.getPN();
            Message('%1', rec.PartNo);

            CurrPage.Update(false);
            Clear(opPage);
        end;
    end;

    var
        opPage: Page OptionLineList;
        oCU: Codeunit "OP Page Manager";
        hRec: Record "Sales Order Entity Buffer";
}