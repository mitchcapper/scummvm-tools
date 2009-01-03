/* tool_gui - GUI for all the tools
 * Copyright (C) 2007  The ScummVM Team
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * $URL$
 * $Id$
 *
 */

#include <wx/wx.h>
#include <wx/dnd.h>
#include <wx/notebook.h>
#include <wx/process.h>
#include <wx/txtstrm.h>

class Process;
class LocationDialog;
#if wxUSE_DRAG_AND_DROP
class FileDrop;
#endif
class IOChooser;
class DropDownBox;
class CompressionOptions;
class CompressionPanel;
class ExtractionOptions;
class ExtractionPanel;
class MainFrame;

WX_DEFINE_ARRAY_PTR(Process *, ProcessArray);

/* Default MP3 parameters */
wxString kDefaultMP3ABRAvgBitrate = wxT("24");
wxString kDefaultMP3CompressionType = wxT("VBR");
wxString kDefaultMP3MpegQuality = wxT("2");
wxString kDefaultMP3VBRMaxBitrate = wxT("64");
wxString kDefaultMP3VBRMinBitrate = wxT("24");
wxString kDefaultMP3VBRQuality = wxT("4");

/* Default Vorbis parameters */
wxString kDefaultOggQuality = wxT("3");

/* Default FLAC parameters */
wxString kDefaultFlacCompress = wxT("8");
wxString kDefaultFlacBlocksize = wxT("1152");

/* Compatibility with wx 2.6 */
#if wxMAJOR_VERSION == 2 && wxMINOR_VERSION <= 6
#  define wxFD_OPEN wxOPEN
#  define wxFD_FILE_MUST_EXIST wxFILE_MUST_EXIST
#  define wxFD_MULTIPLE wxMULTIPLE
#endif

#define kNumCompressionTools 12
wxString kCompressionToolNames[12] = {wxT("AGOS"), wxT("Broken Sword 1"), wxT("Broken Sword 2"), wxT("Encode DXA"), wxT("Flight of the Amazon Queen"), wxT("Kyra"), wxT("SAGA"), wxT("SCUMM BUN"), wxT("SCUMM SAN"), wxT("SCUMM SOU"), wxT("Simon 2 (MAC)"), wxT("Touche")};
wxString kCompressionToolFilenames[12] = {wxT("compress_agos"), wxT("compress_sword1"), wxT("compress_sword2"), wxT("encode_dxa"), wxT("compress_queen"), wxT("compress_kyra"), wxT("compress_saga"), wxT("compress_scumm_bun"), wxT("compress_scumm_san"), wxT("compress_scumm_sou"), wxT("compress_agos --mac"), wxT("compress_touche")};

#define kNumExtractionTools 9
wxString kExtractionToolNames[9] = {wxT("AGOS"), wxT("Kyra"), wxT("Loom (TG16)"), wxT("Maniac Mansion (Apple)"), wxT("Maniac Mansion (C64)"), wxT("Maniac Mansion (NES)"), wxT("Parallaction"), wxT("SCUMM (MAC)"), wxT("Zak McKracken (C64)")};
wxString kExtractionToolFilenames[9] = {wxT("extract_agos"), wxT("extract_kyra"), wxT("extract_loom_tg16"), wxT("extract_mm_apple"), wxT("extract_mm_c64"), wxT("extract_mm_nes"), wxT("extract_parallaction"), wxT("extract_scumm_mac"), wxT("extract_zak_c64")};

#define kNumCompressionTypes 3
wxString kCompressionTypeNames[3] = {wxT("MP3"), wxT("Vorbis"), wxT("FLAC")};
wxString kCompressionTypeArguments[3] = {wxT("--mp3"), wxT("--vorbis"), wxT("--flac")};

#define kNumValidBitrates 21
wxString kValidBitrateNames[21] = {wxT(""), wxT("8"), wxT("16"), wxT("24"), wxT("32"), wxT("40"), wxT("48"), wxT("56"), wxT("64"), wxT("72"), wxT("80"), wxT("88"), wxT("96"), wxT("104"), wxT("112"), wxT("120"), wxT("128"), wxT("136"), wxT("144"), wxT("152"), wxT("160")};

#define kNumValidQuality 10
wxString kVaildQualityNames[10] = {wxT("0"), wxT("1"), wxT("2"), wxT("3"), wxT("4"), wxT("5"), wxT("6"), wxT("7"), wxT("8"), wxT("9")};

#define kNumValidCompressionLevels 9
wxString kVaildCompressionLevels[9] = {wxT("0"), wxT("1"), wxT("2"), wxT("3"), wxT("4"), wxT("5"), wxT("6"), wxT("7"), wxT("8")};

#define kNumValidFlacBlocksize 4
wxString kValidFlacBlocksize[4] = {wxT("576"), wxT("1152"), wxT("2304"), wxT("4608")};

#define kNumMP3Modes 2
wxString kMP3ModeNames[2] = {wxT("VBR"), wxT("ABR")};

enum kEventId {
	kCompressionToolChoice,
	kCompressionTypeChoice,
	kCompressionModeChoice,
	kCompressionInputBrowse,
	kCompressionOutputBrowse,
	kCompressionOptionsToggle,
	kCompressionStartButton,
	kExtractionToolChoice,
	kExtractionInput1Browse,
	kExtractionInput2Browse,
	kExtractionOutputBrowse,
	kExtractionStartButton
};


class ToolsGui : public wxApp {
public:
	virtual bool OnInit();
};

/* ----- Main Frame ----- */

class MainFrame : public wxFrame {
public:
	MainFrame(const wxString& title);

	wxNotebook *_mainNotebook;
	CompressionPanel *_compressionTools;
	ExtractionPanel *_extractionTools;
	ProcessArray _processList;

	void OnCompressionOptionsToggle(wxCommandEvent &event);
	void OnCompressionStart(wxCommandEvent &event);
	void OnExtractionStart(wxCommandEvent &event);
	void OnIdle(wxIdleEvent& event);
    void OnProcessTerminated(Process *process);

	DECLARE_EVENT_TABLE()
};

/* ----- Common ----- */

class Process : public wxProcess {
public:
    Process(MainFrame *parent, wxTextCtrl *target);

    MainFrame *_parent;
	wxTextCtrl *_target;

	virtual void OnTerminate(int pid, int status);
    virtual bool HasInput();
};

class LocationDialog {
public:
	LocationDialog(wxTextCtrl *target, bool isFileChooser, wxString wildcard);

	wxDialog *_dialog;
	wxTextCtrl *_target;
	bool _isFileChooser;

	void prompt();
};

#if wxUSE_DRAG_AND_DROP
class FileDrop : public wxFileDropTarget {
public:
	FileDrop(wxTextCtrl *target, bool isFileChooser);

	wxTextCtrl *_target;
	bool _isFileChooser;

	virtual bool OnDropFiles(wxCoord x, wxCoord y, const wxArrayString& filenames);
};
#endif

class IOChooser : public wxPanel {
public:
	IOChooser(wxWindow *parent, kEventId buttonId, wxString title, bool isFileChooser);

	wxTextCtrl *_text;
	wxButton *_browse;
	bool _isFileChooser;
#if wxUSE_DRAG_AND_DROP
	FileDrop *_dropTarget;
#endif
};

class DropDownBox : public wxPanel {
public:
	DropDownBox(wxWindow *parent, kEventId boxId, wxString title, int numItems, wxString items[]);

	wxChoice *_choice;
};

/* ----- Compression ----- */

class CompressionOptions : public wxPanel {
public:
	CompressionOptions(wxWindow *parent);

	wxChoice *_minBitrateChooser;
	wxChoice *_avgBitrateChooser;
	wxChoice *_maxBitrateChooser;
	wxChoice *_vbrQualityChooser;
	wxChoice *_compressionLevelChooser;
	wxChoice *_mpegQualityChooser;
	wxChoice *_modeChooser;
	wxChoice *_blockSize;
	wxCheckBox *_verifyChooser;
	wxCheckBox *_silentChooser;

	void OnCompressionModeChange(wxCommandEvent &event);

	DECLARE_EVENT_TABLE()
};

class CompressionPanel : public wxPanel {
public:
	CompressionPanel(wxWindow *parent);

	DropDownBox *_compressionToolChooserBox;
	DropDownBox *_compressionTypeBox;
	wxCheckBox *_compressionOptionsChooser;
	IOChooser *_inputPanel;
	IOChooser *_outputPanel;
	CompressionOptions *_compressionOptionsPanel;
	wxButton *_startButton;
	wxTextCtrl *_toolOutput;

	void OnCompressionToolChange(wxCommandEvent &event);
	void OnCompressionTypeChange(wxCommandEvent &event);
	void OnCompressionInputBrowse(wxCommandEvent &event);
	void OnCompressionOutputBrowse(wxCommandEvent &event);

	DECLARE_EVENT_TABLE()
};

/* ----- Extraction ----- */

class ExtractionOptions : public wxPanel {
public:
	ExtractionOptions(wxWindow *parent);

	wxCheckBox *_kyraAmiga;
	wxCheckBox *_kyraAllFiles;
	wxCheckBox *_kyraSingleFile;
	wxTextCtrl *_kyraFilename;
	wxCheckBox *_parallactionSmall;
};

class ExtractionPanel : public wxPanel {
public:
	ExtractionPanel(wxWindow *parent);

	DropDownBox *_extractionToolChooserPanel;
	IOChooser *_input1Panel;
	IOChooser *_input2Panel;
	IOChooser *_outputPanel;
	ExtractionOptions *_extractionOptionsPanel;
	wxButton *_startButton;
	wxTextCtrl *_toolOutput;

	void OnExtractionToolChange(wxCommandEvent &event);
	void OnExtractionInput1Browse(wxCommandEvent &event);
	void OnExtractionInput2Browse(wxCommandEvent &event);
	void OnExtractionOutputBrowse(wxCommandEvent &event);

	DECLARE_EVENT_TABLE()
};
