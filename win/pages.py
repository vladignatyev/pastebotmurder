import wx
import wx.wizard
from wx.webkit import WebKitCtrl

class TitledPage(wx.wizard.WizardPageSimple):
  def __init__(self, parent, title):
    wx.wizard.WizardPageSimple.__init__(self,parent)
    self.web = WebKitCtrl(self, -1, 'http://google.com', (10,10), (500,500))
    
if __name__ == "__main__":
  app = wx.PySimpleApp()
  wizard = wx.wizard.Wizard(None, -1, "Simple Wizrad")
  page1 = TitledPage(wizard, "Page 1")
  page2 = TitledPage(wizard, "Page 2")
  page3 = TitledPage(wizard, "Page 3")
  page4 = TitledPage(wizard, "Page 4")
  wx.wizard.WizardPageSimple_Chain(page1, page2)
  wx.wizard.WizardPageSimple_Chain(page2, page3)
  wx.wizard.WizardPageSimple_Chain(page3, page4)
  wizard.FitToPage(page1)

  if wizard.RunWizard(page1):
    print "Success"
