tableextension 50109 SalesInvLineExt extends "Sales Invoice Line"
{
    fields
    {
        field(50104; PartNumber; Text[100])
        {
            TableRelation = "Intermediary Part Table".PartNumber;
            DataClassification = ToBeClassified;
            Editable = False;
            trigger OnValidate()
            var
                PartsRec: Record "Intermediary Part Table";
                ItemRec: Record Item;
            begin
                if Rec.PartNumber = '' then begin
                    // Don't perform the lookup if PartNumber is empty
                    exit;
                end;

                if PartsRec.Get(Rec.PartNumber) then begin
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