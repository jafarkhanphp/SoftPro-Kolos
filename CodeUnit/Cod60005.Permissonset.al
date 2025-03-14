permissionset 60005 GeneratedPermission
{
    Assignable = true;
    Permissions = tabledata "ABS Container Content" = RIMD,
        tabledata "Sales Invoice Header" = RIMD,
        tabledata EInvoice = RIMD,
        tabledata EInvoiceHistory = RIMD,
        tabledata "Mra Api Setup" = RIMD,
        tabledata TempBlob = RIMD,
        table "Sales Invoice Header" = X,
        table TempBlob = X,
        table EInvoice = X,
        table EInvoiceHistory = X,
        table "MRA API Setup" = X,
        page MraApiSetup = X;
}