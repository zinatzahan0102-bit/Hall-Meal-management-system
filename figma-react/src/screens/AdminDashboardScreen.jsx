import React, { useState } from 'react';
import { Users, Utensils, MessageSquareCode, ShieldAlert, Settings, LogOut, Plus, Star, Check, CheckCircle2, ChevronRight, Save } from 'lucide-react';

export default function AdminDashboardScreen({ onNavigate, user, onLogout }) {
  const [activeTab, setActiveTab] = useState('students');
  
  // MOCK DATA STATES FOR ADMIN ACTIONS
  // 1. Students list
  const [students, setStudents] = useState([
    { name: 'Zinat Zahan', id: '20210804', room: '402-B', activeMeals: 48 },
    { name: 'Sajid Islam', id: '20210812', room: '311-A', activeMeals: 36 },
    { name: 'Sadia Rahman', id: '20210819', room: '204-C', activeMeals: 52 },
  ]);
  const [newStudent, setNewStudent] = useState({ name: '', id: '', room: '' });
  const [showAddModal, setShowAddModal] = useState(false);

  // 2. Menu edit
  const [menuItems, setMenuItems] = useState({
    Breakfast: 'Paratha (2 pcs), Egg Omelette, Dal Fry',
    Lunch: 'Plain Rice, Beef Curry, Potato Vorta, Lentil Soup',
    Dinner: 'Plain Rice, Fish Curry (Rui), Mixed Vegetable',
  });
  const [rates, setRates] = useState({ Breakfast: 25, Lunch: 65, Dinner: 45 });
  const [isSaved, setIsSaved] = useState(false);

  // 3. Feedback lists
  const [complaints, setComplaints] = useState([
    { id: 'CMP-203', name: 'Zinat Zahan', type: 'Food Quality', desc: 'Rice was undercooked in lunch today.', status: 'Pending', reply: '' },
    { id: 'CMP-202', name: 'Sajid Islam', type: 'Service', desc: 'Water filter near dining table was empty.', status: 'Resolved', reply: 'Filter has been refilled.' }
  ]);
  const [activeFeedbackSubTab, setActiveFeedbackSubTab] = useState('complaints');
  const [adminReplyText, setAdminReplyText] = useState({});

  // 4. Global Settings
  const [cutoffHour, setCutoffHour] = useState('20:00');
  const [monthlyLimit, setMonthlyLimit] = useState(60);

  // HANDLERS
  const handleAddStudent = (e) => {
    e.preventDefault();
    if (!newStudent.name || !newStudent.id || !newStudent.room) return;
    setStudents([...students, { ...newStudent, activeMeals: 0 }]);
    setNewStudent({ name: '', id: '', room: '' });
    setShowAddModal(false);
  };

  const handleSaveMenu = (e) => {
    e.preventDefault();
    setIsSaved(true);
    setTimeout(() => setIsSaved(false), 2000);
  };

  const handleResolveComplaint = (id) => {
    const reply = adminReplyText[id] || 'Action has been taken to resolve this issue.';
    setComplaints(complaints.map(c => 
      c.id === id ? { ...c, status: 'Resolved', reply } : c
    ));
  };

  return (
    <div className="flex-1 flex flex-col justify-between bg-background-soft select-none overflow-hidden relative">
      {/* Top Admin Header Bar */}
      <div className="bg-gradient-to-br from-gray-900 to-gray-950 p-5 rounded-b-[28px] text-white shadow-lg z-10">
        <div className="flex justify-between items-center mt-4">
          <div className="text-left">
            <span className="text-[9px] bg-primary/20 text-primary border border-primary/20 font-bold px-2 py-0.5 rounded-full uppercase tracking-widest">
              Admin console
            </span>
            <h3 className="font-extrabold text-base leading-tight mt-1">Dashboard Management</h3>
          </div>
          
          <button
            onClick={() => {
              onLogout();
              onNavigate('login');
            }}
            className="w-9 h-9 rounded-xl bg-white/10 flex items-center justify-center hover:bg-white/20 transition-all border border-white/5"
            title="Log Out"
          >
            <LogOut size={16} />
          </button>
        </div>
      </div>

      {/* Main Tab Switcher Bar */}
      <div className="bg-white border-b border-gray-100 flex overflow-x-auto no-scrollbar py-2 px-3 text-[10px] font-black tracking-wide uppercase text-text-secondary z-10 shadow-xs">
        {[
          { id: 'students', label: 'Students', icon: Users },
          { id: 'menu', label: 'Menu', icon: Utensils },
          { id: 'chat', label: 'Chats', icon: MessageSquareCode },
          { id: 'feedback', label: 'Feedback', icon: ShieldAlert },
          { id: 'settings', label: 'Rules', icon: Settings },
        ].map((tab) => {
          const Icon = tab.icon;
          const isActive = activeTab === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`flex items-center gap-1 px-3 py-2 rounded-xl transition-all font-bold shrink-0 ${
                isActive ? 'bg-primary/10 text-primary' : 'hover:bg-gray-100'
              }`}
            >
              <Icon size={12} />
              <span>{tab.label}</span>
            </button>
          );
        })}
      </div>

      {/* Dynamic Tab Body Panel */}
      <div className="flex-1 overflow-y-auto no-scrollbar px-4 py-4">
        {/* TABS CONTAINER */}

        {/* 1. STUDENTS TAB */}
        {activeTab === 'students' && (
          <div className="space-y-4 text-left">
            <div className="flex justify-between items-center bg-white p-4 rounded-3xl border border-primary/5 shadow-xs">
              <div>
                <h4 className="font-bold text-xs text-text-secondary uppercase">Active Students</h4>
                <p className="text-2xl font-black text-text-primary mt-0.5">{students.length}</p>
              </div>
              <button
                onClick={() => setShowAddModal(true)}
                className="flex items-center gap-1 bg-primary text-white text-xs font-bold px-3 py-2 rounded-xl hover:bg-primary-dark shadow-md"
              >
                <Plus size={14} />
                <span>Add Student</span>
              </button>
            </div>

            <div className="space-y-2.5">
              {students.map((student) => (
                <div key={student.id} className="bg-white p-4 rounded-2xl shadow-xs border border-primary/5 flex justify-between items-center">
                  <div>
                    <h5 className="font-extrabold text-sm text-text-primary">{student.name}</h5>
                    <p className="text-[10px] text-text-secondary mt-0.5">ID: {student.id} | Room: {student.room}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-[9px] text-text-secondary font-bold">Month Meals</p>
                    <span className="text-xs font-black text-primary bg-primary/10 px-2 py-0.5 rounded-full inline-block mt-0.5">
                      {student.activeMeals}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* 2. MENU EDIT TAB */}
        {activeTab === 'menu' && (
          <form onSubmit={handleSaveMenu} className="space-y-4 text-left bg-white p-5 rounded-3xl border border-primary/5 shadow-xs">
            <div className="flex justify-between items-center mb-1">
              <h4 className="font-extrabold text-sm text-text-primary">Edit Daily Meals</h4>
              {isSaved && (
                <span className="text-[10px] text-primary font-bold bg-primary/15 px-2 py-0.5 rounded-full flex items-center gap-1">
                  <Check size={12} className="stroke-[3]" /> Saved
                </span>
              )}
            </div>

            {['Breakfast', 'Lunch', 'Dinner'].map((meal) => (
              <div key={meal} className="space-y-1">
                <div className="flex justify-between items-center text-[10px] font-extrabold">
                  <span className="text-text-primary uppercase tracking-wide">{meal} Menu</span>
                  <div className="flex items-center gap-1 text-text-secondary">
                    <span>Rate (৳):</span>
                    <input
                      type="number"
                      value={rates[meal]}
                      onChange={(e) => setRates({ ...rates, [meal]: parseInt(e.target.value) || 0 })}
                      className="w-12 px-1 py-0.5 bg-background-soft border border-primary/10 rounded-md text-center focus:outline-none focus:ring-1 focus:ring-primary"
                    />
                  </div>
                </div>
                <textarea
                  value={menuItems[meal]}
                  onChange={(e) => setMenuItems({ ...menuItems, [meal]: e.target.value })}
                  rows="2"
                  className="w-full p-2.5 bg-background-soft border border-primary/10 rounded-xl text-xs focus:outline-none focus:ring-1 focus:ring-primary placeholder:text-text-secondary/50 resize-none font-medium leading-relaxed"
                />
              </div>
            ))}

            <button
              type="submit"
              className="w-full py-3 bg-primary text-white font-extrabold text-xs rounded-2xl hover:bg-primary-dark shadow-md flex items-center justify-center gap-1.5"
            >
              <Save size={14} />
              <span>Save Menu Changes</span>
            </button>
          </form>
        )}

        {/* 3. CHAT TAB */}
        {activeTab === 'chat' && (
          <div className="space-y-3.5 text-left">
            <div className="bg-white p-4 rounded-2xl border border-primary/5 text-center text-xs text-text-secondary">
              Active student communication channels
            </div>
            
            {/* Chat List Items */}
            {['Group Lounge', 'Block A Queries', 'Block B Queries'].map((room, idx) => (
              <div key={idx} className="bg-white p-4 rounded-2xl shadow-xs border border-primary/5 flex justify-between items-center cursor-pointer hover:bg-gray-50/50">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-accent/10 border border-accent/20 flex items-center justify-center text-accent-dark font-extrabold text-xs">
                    #
                  </div>
                  <div>
                    <h5 className="font-extrabold text-xs text-text-primary">{room}</h5>
                    <p className="text-[10px] text-text-secondary mt-0.5">Last message: We updated tomorrow's menu...</p>
                  </div>
                </div>
                <ChevronRight size={15} className="text-text-secondary" />
              </div>
            ))}
          </div>
        )}

        {/* 4. FEEDBACK / MODERATION TAB */}
        {activeTab === 'feedback' && (
          <div className="space-y-3.5 text-left">
            {/* Toggle Feedback Subtabs */}
            <div className="flex bg-white rounded-xl p-1 border border-primary/5 shadow-inner text-[10px] font-bold">
              <button
                onClick={() => setActiveFeedbackSubTab('complaints')}
                className={`flex-1 py-1.5 text-center rounded-lg transition-all ${
                  activeFeedbackSubTab === 'complaints' ? 'bg-primary text-white shadow-xs' : 'text-text-secondary'
                }`}
              >
                Complaints ({complaints.length})
              </button>
              <button
                onClick={() => setActiveFeedbackSubTab('reviews')}
                className={`flex-1 py-1.5 text-center rounded-lg transition-all ${
                  activeFeedbackSubTab === 'reviews' ? 'bg-primary text-white shadow-xs' : 'text-text-secondary'
                }`}
              >
                Student Reviews
              </button>
            </div>

            {activeFeedbackSubTab === 'complaints' ? (
              <div className="space-y-3">
                {complaints.map((c) => (
                  <div key={c.id} className="bg-white p-4 rounded-2xl shadow-xs border border-primary/5 space-y-2">
                    <div className="flex justify-between items-center">
                      <div className="flex items-center gap-1.5">
                        <span className="text-xs font-black text-text-primary">{c.id}</span>
                        <span className="text-[9px] font-bold text-text-secondary bg-gray-100 px-2 py-0.5 rounded-full">{c.type}</span>
                      </div>
                      <span
                        className={`text-[9px] font-black px-2 py-0.5 rounded-full uppercase tracking-wider ${
                          c.status === 'Resolved' ? 'bg-primary/10 text-primary' : 'bg-accent/15 text-accent-dark'
                        }`}
                      >
                        {c.status}
                      </span>
                    </div>

                    <div>
                      <p className="text-[10px] text-text-secondary font-semibold">Filed by: {c.name}</p>
                      <p className="text-xs text-text-primary mt-1 font-medium leading-relaxed">{c.desc}</p>
                    </div>

                    {c.status === 'Pending' ? (
                      <div className="pt-2 border-t border-gray-100 space-y-2">
                        <input
                          type="text"
                          placeholder="Type resolution response..."
                          value={adminReplyText[c.id] || ''}
                          onChange={(e) => setAdminReplyText({ ...adminReplyText, [c.id]: e.target.value })}
                          className="w-full px-3 py-1.5 bg-background-soft border border-primary/10 rounded-xl text-[11px] focus:outline-none focus:ring-1 focus:ring-primary"
                        />
                        <button
                          onClick={() => handleResolveComplaint(c.id)}
                          className="flex items-center gap-1 bg-primary text-white text-[10px] font-bold px-3 py-1.5 rounded-xl hover:bg-primary-dark shadow-xs"
                        >
                          <Check size={12} className="stroke-[3]" />
                          <span>Resolve Issue</span>
                        </button>
                      </div>
                    ) : (
                      <div className="p-2.5 bg-background-soft rounded-xl border-l-2 border-primary text-[10px] text-text-secondary leading-relaxed">
                        <p className="font-bold text-primary text-[9px] uppercase">Reply Logged</p>
                        <p className="mt-0.5">{c.reply}</p>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            ) : (
              <div className="space-y-3">
                {/* Simulated Reviews list */}
                <div className="bg-white p-4 rounded-2xl shadow-xs border border-primary/5 space-y-1.5">
                  <div className="flex justify-between items-center">
                    <span className="text-xs font-bold text-text-primary">Zinat Zahan</span>
                    <div className="flex gap-0.5">
                      {Array.from({ length: 5 }).map((_, i) => (
                        <Star key={i} size={10} className="fill-accent stroke-accent" />
                      ))}
                    </div>
                  </div>
                  <p className="text-xs text-text-secondary">Beef curry today was absolutely amazing! Great quality.</p>
                </div>
              </div>
            )}
          </div>
        )}

        {/* 5. SETTINGS / RULES TAB */}
        {activeTab === 'settings' && (
          <div className="space-y-4 text-left bg-white p-5 rounded-3xl border border-primary/5 shadow-xs">
            <h4 className="font-extrabold text-sm text-text-primary mb-1">Global System Parameters</h4>

            {/* Cutoff Time */}
            <div className="space-y-1">
              <label className="text-[10px] font-bold text-text-secondary uppercase">Meal Action Cut-Off Time</label>
              <input
                type="time"
                value={cutoffHour}
                onChange={(e) => setCutoffHour(e.target.value)}
                className="w-full px-3 py-2.5 bg-background-soft border border-primary/10 rounded-2xl text-xs focus:outline-none focus:ring-1 focus:ring-primary font-bold"
              />
            </div>

            {/* Monthly Limit */}
            <div className="space-y-1 mt-2">
              <label className="text-[10px] font-bold text-text-secondary uppercase">Max Monthly Meal Limit</label>
              <input
                type="number"
                value={monthlyLimit}
                onChange={(e) => setMonthlyLimit(parseInt(e.target.value) || 0)}
                className="w-full px-3 py-2.5 bg-background-soft border border-primary/10 rounded-2xl text-xs focus:outline-none focus:ring-1 focus:ring-primary font-bold"
              />
            </div>

            <button
              onClick={() => alert('Global settings saved!')}
              className="w-full mt-2 py-3 bg-primary text-white font-extrabold text-xs rounded-2xl hover:bg-primary-dark shadow-md flex items-center justify-center gap-1.5"
            >
              <Save size={14} />
              <span>Save System Rules</span>
            </button>
          </div>
        )}
      </div>

      {/* Bottom Sheet modal simulation */}
      {showAddModal && (
        <div className="absolute inset-0 bg-black/60 backdrop-blur-xs z-50 flex items-end animate-fade-in">
          <form onSubmit={handleAddStudent} className="w-full bg-white rounded-t-[32px] p-6 shadow-2xl border-t border-primary/15 animate-slide-up space-y-4 text-left">
            <div className="flex justify-between items-center">
              <h4 className="font-extrabold text-sm text-text-primary">Register New Student</h4>
              <button
                type="button"
                onClick={() => setShowAddModal(false)}
                className="w-8 h-8 rounded-full bg-background-soft flex items-center justify-center text-text-secondary hover:bg-gray-200"
              >
                X
              </button>
            </div>

            {/* Inputs */}
            <div className="space-y-1">
              <label className="text-[10px] font-bold text-text-secondary">Full Name</label>
              <input
                type="text"
                required
                value={newStudent.name}
                onChange={(e) => setNewStudent({ ...newStudent, name: e.target.value })}
                placeholder="e.g. Sajid Islam"
                className="w-full px-3 py-2 bg-background-soft border border-primary/10 rounded-xl text-xs focus:outline-none focus:ring-1 focus:ring-primary"
              />
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <label className="text-[10px] font-bold text-text-secondary">Student ID</label>
                <input
                  type="text"
                  required
                  value={newStudent.id}
                  onChange={(e) => setNewStudent({ ...newStudent, id: e.target.value })}
                  placeholder="e.g. 20210815"
                  className="w-full px-3 py-2 bg-background-soft border border-primary/10 rounded-xl text-xs focus:outline-none focus:ring-1 focus:ring-primary"
                />
              </div>
              <div className="space-y-1">
                <label className="text-[10px] font-bold text-text-secondary">Room Number</label>
                <input
                  type="text"
                  required
                  value={newStudent.room}
                  onChange={(e) => setNewStudent({ ...newStudent, room: e.target.value })}
                  placeholder="e.g. 312-C"
                  className="w-full px-3 py-2 bg-background-soft border border-primary/10 rounded-xl text-xs focus:outline-none focus:ring-1 focus:ring-primary"
                />
              </div>
            </div>

            <button
              type="submit"
              className="w-full mt-2 py-3 bg-primary text-white font-extrabold text-xs rounded-2xl hover:bg-primary-dark shadow-md"
            >
              Add Student Record
            </button>
          </form>
        </div>
      )}

      {/* Bottom status bar indicator */}
      <div className="h-6 bg-white border-t border-gray-100 flex items-center justify-center">
        <div className="w-20 h-1 bg-gray-300 rounded-full"></div>
      </div>
    </div>
  );
}
