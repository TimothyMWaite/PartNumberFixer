codeunit 50106 ItemOptions
{

    procedure getItemRecord(): Record Item

    begin
        exit(currentItem);
    end;

    procedure setItemRecord(var itemRec: Record Item)
    begin
        currentItem := itemRec;
    end;

    trigger OnRun()
    begin
        currentItem := getItemRecord();
    end;

    var
        currentItem: Record Item;
}