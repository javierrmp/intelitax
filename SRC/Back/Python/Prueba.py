from zipfile import ZipFile

with ZipFile('984A1732-AA99-43C9-B400-53677E672C56_01.zip', 'r') as zipObj:
   # Get list of files names in zip
   listOfiles = zipObj.namelist()
   # Iterate over the list of file names in given list & print them
   for elem in listOfiles:
       print(elem)