tableextension 50109 SalesInvLineExt extends "Sales Invoice Line"
{
    fields
    {
        field(50104; PartNo; Text[100])
        {
            TableRelation = "Intermediary Part Table".PartNo;
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                PartsRec: Record "Intermediary Part Table";
                ItemRec: Record Item;
            begin
                if Rec.PartNo = '' then begin
                    // Don't perform the lookup if PartNo is empty
                    exit;
                end;

                if PartsRec.Get(Rec.PartNo) then begin
                    if ItemRec.Get(PartsRec."Item ID") then begin
                        if ItemRec.Blocked then begin
                            Error('This item is blocked.');
                        end;

                        Rec."No." := ItemRec."No.";
                        Rec.Description := ItemRec.Description;
                        Rec."Unit of Measure Code" := ItemRec."Base Unit of Measure";
                        Rec."Unit Price" := ItemRec."Unit Price";
                        Rec."Tax Group Code" := ItemRec."Tax Group Code";
                    end else begin
                        Error('Item not found.');
                    end;
                end else begin
                    Error('Part Number not found.');
                end;
            end;

        }

    }
}