require 'spec_helper'

describe LessonsController do


  describe 'show test' do
    it 'show the correct id page' do
      fake_lesson = mock('Lesson', :id => '1')
      fake_videos = [mock('Video', :id => '1'),mock('Video', :id => '2')]
      fake_documents = [mock('Document', :id => '1'),mock('Document', :id => '2')]
      fake_prezis = [mock('Prezi', :id => '1'),mock('Prezi', :id => '2')]
      fake_comments = [mock('Comment', :id => '1'),mock('Comment', :id => '2')]
      Lesson.should_receive(:find).with('1').
        and_return(fake_lesson)
      fake_lesson.stub(:documents).
        and_return(fake_documents)
      fake_documents.should_receive(:order).with(:position).
        and_return(fake_documents)

      fake_lesson.stub(:prezis).
        and_return(fake_prezis)
      fake_prezis.should_receive(:order).with(:position).
        and_return(fake_prezis)

      fake_lesson.stub(:videos).
        and_return(fake_videos)
      fake_videos.should_receive(:order).with(:position).
        and_return(fake_videos)

      fake_lesson.should_receive(:comments).
        and_return(fake_comments)

      post :show, {:id => '1',:page => '1'}
      response.should render_template('show')
      assigns(:lesson).should == fake_lesson
      assigns(:documents).should == fake_documents
      assigns(:prezis).should == fake_prezis
      assigns(:videos).should == fake_videos
      assigns(:totalpage).should == 1
      assigns(:currentpage).should == '1'
      assigns(:comments).should == fake_comments
    end
    
    describe 'page not correct' do
      before :each do
        @fake_lesson = mock('Lesson', :id => '1')
        @fake_videos = [mock('Video', :id => '1'),mock('Video', :id => '2')]
        @fake_documents = [mock('Document', :id => '1'),mock('Document', :id => '2')]
        @fake_prezis = [mock('Prezi', :id => '1'),mock('Prezi', :id => '2')]
        @fake_comments = [mock('Comment', :id => '1'),mock('Comment', :id => '2')]
        Lesson.stub(:find).
          and_return(@fake_lesson)
        @fake_lesson.stub(:documents).
          and_return(@fake_documents)
        @fake_documents.stub(:order).
          and_return(@fake_documents)
  
        @fake_lesson.stub(:prezis).
          and_return(@fake_prezis)
        @fake_prezis.stub(:order).
          and_return(@fake_prezis)
  
        @fake_lesson.stub(:videos).
          and_return(@fake_videos)
        @fake_videos.stub(:order).
          and_return(@fake_videos)
  
        @fake_lesson.stub(:comments).
          and_return(@fake_comments)
      end
      
      it 'show the first page due to nil pass in' do
        post :show, {:id => '1',:page => nil}
      end
      
      it 'goes out of comment page range' do
        post :show, {:id => '1',:page => '2'}
      end
      
      after :each do
        response.should render_template('show')
        assigns(:lesson).should == @fake_lesson
        assigns(:documents).should == @fake_documents
        assigns(:prezis).should == @fake_prezis
        assigns(:videos).should == @fake_videos
        assigns(:totalpage).should == 1
        assigns(:currentpage).should == 1
        assigns(:comments).should == @fake_comments     
      end
    end
    
    it 'show Lesson not found.' do
      allow_message_expectations_on_nil
      Lesson.should_receive(:find).with('10').
        should raise_error
      nil.should_receive(:documents).and_raise("")
      post :show, {:id => '10'}
      response.should redirect_to('/lessons')
    end

  end

  describe 'index test' do
    it 'show the index page' do
      Lesson.should_receive(:order).with(:position)
      post :index
      response.should render_template('index')
    end
  end

  describe 'new, create, edit, update, destroy test' do
    before :each do
      @invalid_fake_lesson = {'title' => '', "description" => 'sample lesson'}
      @fake_lesson = {'title' => 'lesson1', "description" => 'sample lesson'}
      @fake_result = mock('Lesson', :id => '1', :title => 'lesson1', :description => 'sample lesson')
      controller.stub(:admin?).and_return(true)
      @fake_result.stub(:position=)
    end
    it 'should go to new page' do
      post :new
      response.should render_template('new')
    end
    it 'should create the lesson page' do
      Lesson.should_receive(:new).with(@fake_lesson).
        and_return(@fake_result)
      @fake_result.should_receive(:save).and_return(true)
      post :create, {:lesson => @fake_lesson}
    end

    it 'should appear the created the lesson in home page' do
      Lesson.stub(:new).with(@fake_lesson).
        and_return(@fake_result)
      @fake_result.should_receive(:save).and_return(true)
      post :create, {:lesson => @fake_lesson}
      response.should redirect_to('/lessons')
    end

    it 'show You must enter a title for lesson.' do
      Lesson.should_receive(:new).with(@invalid_fake_lesson).and_return(@fake_result)
      @fake_result.should_receive(:save).and_return(false)
      post :create, {:lesson => @invalid_fake_lesson}
      response.should redirect_to('/lessons/new')
    end

    it 'should go to the edit page of the lesson' do
      Lesson.should_receive(:find).with('1').
        and_return(@fake_result)
      post :edit, {:id => '1'}
      response.should render_template('edit')
    end

    it 'show Lesson not found.' do
      Lesson.stub(:find).with('10').
        and_raise(ActiveRecord::RecordNotFound)
      post :edit, {:id => '10'}
      response.should redirect_to('/lessons')
    end

    it 'should update the lesson page' do
      Lesson.stub(:find).
        and_return(@fake_result)
      @fake_result.should_receive(:update_attributes!).with(@fake_lesson)
      post :update, {:id => '1', :lesson => @fake_lesson}
      response.should redirect_to(lesson_path(@fake_result))
    end

    it 'show You must enter a title for lesson.' do
      Lesson.stub(:find).
        and_return(@fake_result)
      @fake_result.stub(:update_attributes!).with(@invalid_fake_lesson).
        and_raise(ActiveRecord::RecordInvalid)
      post :update, {:id => '1', :lesson => @invalid_fake_lesson}
      response.should redirect_to(edit_lesson_path(@fake_result))
    end

    it 'should destroy the lesson page' do
      Lesson.stub(:find).
        and_return(@fake_result)
      @fake_result.should_receive(:destroy)
      post :destroy, {:id => '1'}
      response.should redirect_to('/lessons')
    end
  end

  describe 'lesson sorting' do
    before :each do
      @fake_lesson1 = mock('Lesson', :id => '1', :title => 'lesson1', :description => 'sample lesson 1')
      @fake_lesson2 = mock('Lesson', :id => '2', :title => 'lesson2', :description => 'sample lesson 2')
      @fake_lesson3 = mock('Lesson', :id => '3', :title => 'lesson3', :description => 'sample lesson 3')
    end

    it 'should set the position' do
      Lesson.should_receive(:find).with(1).and_return(@fake_lesson1)
      @fake_lesson1.should_receive(:position=).with(0)
      @fake_lesson1.should_receive(:save).and_return(true)
      Lesson.should_receive(:find).with(2).and_return(@fake_lesson2)
      @fake_lesson2.should_receive(:save).and_return(true)
      @fake_lesson2.should_receive(:position=).with(2)
      Lesson.should_receive(:find).with(3).and_return(@fake_lesson3)
      @fake_lesson3.should_receive(:position=).with(1)
      @fake_lesson3.should_receive(:save).and_return(true)
      post :sort, {"lessons"=>["1", "3", "2"]}
    end
  end

 describe 'check reorder' do
   it 'should change to the set order' do
     fake_lessons = [mock('Lesson', :id => '1', :title => 'lesson1', :description => 'sample lesson 1')]
     Lesson.should_receive(:order).with(:position).
       and_return(fake_lessons)
     post :reorder
   end
 end

end


