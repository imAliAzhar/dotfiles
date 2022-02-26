#!/usr/bin/osascript -l JavaScript
app = Application.currentApplication();
app.includeStandardAdditions = true;

const VAULT_HOME = "/Users/imaliazhar/Documents";
const DAILY_VAULT_NAME = "Gringotts";
const DAILY_VAULT_PATH = VAULT_HOME + "/" + DAILY_VAULT_NAME;
const DAILY_DIR_NAME = "Daily Notes";
const DAILY_TEMPLATE_PATH = DAILY_VAULT_PATH + "/Templates/Daily Notes.md";

const MONTHS = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];

const DAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

const finder = Application("Finder");

const log = (obj) => console.log(JSON.stringify(obj));

const left_pad_date = (d) => {
  if (d > 9) return d.toString();
  else return "0" + d.toString();
};

const make_folder_exist = (at, folder) => {
  const folder_path_str = `${at}/${folder}`;
  const folder_path = Path(folder_path_str);
  const exists = finder.exists(folder_path);

  if (exists) {
    log(`folder exists: ${folder_path_str}`);
    return;
  }

  const at_path = Path(at);

  finder.make({
    new: "folder",
    at: at_path,
    withProperties: { name: folder },
  });

  log(`folder created: ${folder_path_str}`);
};

const make_path_exist = (at, ...folders) => {
  folders.reduce((nestedAt, folder) => {
    make_folder_exist(nestedAt, folder);
    return `${nestedAt}/${folder}`;
  }, at);
};

const get_todays_strings = () => {
  const today = new Date();

  const yyyy = today.getFullYear().toString();
  const mm = MONTHS[today.getMonth()];
  const dd = left_pad_date(today.getDate().toString());
  const day = DAYS[today.getDay()];

  return { yyyy, mm, dd, day };
};

const get_obsidian_uri = (note_vault_path) => {
  const vault_name = encodeURIComponent(DAILY_VAULT_NAME);
  const file_path = encodeURIComponent(note_vault_path);
  return `obsidian://open?vault=${vault_name}&file=${file_path}`;
};

const get_template_text = () => {
  const template_path = Path(DAILY_TEMPLATE_PATH);
  return app.read(template_path);
};

const main = () => {
  const { yyyy, mm, dd, day } = get_todays_strings();

  const note_file = `${dd}-${day}.md`;
  const note_vault_path_str = `${DAILY_DIR_NAME}/${yyyy}/${mm}/${note_file}`;
  const note_path_str = `${DAILY_VAULT_PATH}/${note_vault_path_str}`;
  const note_path = Path(note_path_str);

  const does_note_exist = finder.exists(note_path);

  if (!does_note_exist) {
    log(`${note_path_str} does not exist`);
    make_path_exist(DAILY_VAULT_PATH, DAILY_DIR_NAME, yyyy, mm);

    const template_text = get_template_text();

    const opened_note = app.openForAccess(note_path, { writePermission: true });

    app.write(template_text, {
      to: opened_note,
      startingAt: app.getEof(opened_note),
    });
    app.closeAccess(opened_note);
    // wait a bit for note to show up in file system
    delay(1);
  }

  const uri = get_obsidian_uri(note_vault_path_str);
  app.openLocation(uri);
};

main();
