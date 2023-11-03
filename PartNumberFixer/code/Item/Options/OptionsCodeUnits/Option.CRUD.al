codeunit 50109 OptionCRUD
{
    procedure CreateOption(var newOption: Record "Option"): Boolean
    var
        oldOption: Record Option;
    begin
        if oldOption.FindLast() then begin

            newOption.Init();




        end else begin
            newOption.Id := 1000;
        end;
        exit(newOption.Insert(true));
    end;

    procedure ReadOption(optionId: Code[20]; var foundOption: Record "Option"): Boolean
    begin
        exit(foundOption.Get(optionId));
    end;

    procedure UpdateOption(var updatedOption: Record "Option"): Boolean
    begin
        exit(updatedOption.Modify());
    end;

    procedure DeleteOption(var optionToDelete: Record "Option"): Boolean
    begin
        exit(optionToDelete.Delete(true));
    end;

}
