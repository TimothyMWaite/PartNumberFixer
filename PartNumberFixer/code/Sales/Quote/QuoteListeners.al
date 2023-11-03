codeunit 50144 MySubscribers
{
    // [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeModifyEvent', '', false, false)]
    // local procedure MyBeforeModifyProcedure(var Rec: Record "Sales Line")
    // var
    //     ItemRec: Record Item;
    //     IntermediaryPartRec: Record "Intermediary Part Table";
    // begin
    //     // If PartNo is empty, try to fill it based on the No. field
    //     Message('In listener');
    //     if Rec.PartNo = '' then begin
    //         if ItemRec.Get(Rec."No.") then begin
    //             Rec.PartNo := ItemRec.PartNo;
    //         end;
    //     end else begin
    //         // If PartNo is set, update other fields accordingly
    //         if IntermediaryPartRec.Get(Rec.PartNo) then begin
    //             if ItemRec.Get(IntermediaryPartRec."Item ID") then begin
    //                 // Only set the fields if they are empty
    //                 if Rec."No." = '' then
    //                     Rec."No." := ItemRec."No.";
    //                 if Rec.Description = '' then
    //                     Rec.Description := ItemRec.Description;
    //                 if Rec."Unit Price" = 0 then
    //                     Rec."Unit Price" := ItemRec."Unit Price";
    //                 if Rec."Tax Group Code" = '' then
    //                     Rec."Tax Group Code" := ItemRec."Tax Group Code";
    //             end else begin
    //                 Error('Item not found.');
    //             end;
    //         end else begin
    //             Error('Part Number not found.');
    //         end;
    //     end;
    // end;
}
